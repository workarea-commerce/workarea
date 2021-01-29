module Workarea
  class Release
    include ApplicationDocument
    include Mongoid::Document::Taggable
    include Commentable

    field :name, type: String
    field :publish_at, type: Time
    field :published_at, type: Time
    field :publish_job_id, type: String
    field :undo_at, type: Time # TODO deprecated, remove in v3.6
    field :undone_at, type: Time # TODO deprecated, remove in v3.6
    field :undo_job_id, type: String # TODO deprecated, remove in v3.6

    has_many :changesets, class_name: 'Workarea::Release::Changeset'
    has_many :undos, class_name: 'Workarea::Release', inverse_of: :undoes
    belongs_to :undoes, class_name: 'Workarea::Release', inverse_of: :undo, optional: true

    index({ publish_at: 1 })
    index({ published_at: 1 })

    validates :name, presence: true
    validate :publish_at_status

    after_find :reset_preview
    before_save :remove_publish_job, if: Proc.new { |r| r.publish_at.blank? }
    before_save :schedule_publish
    after_save :reset_preview
    before_destroy :remove_publish_job

    scope :not_published, -> { where(published_at: nil) }
    scope :published, (lambda do
      where(:published_at.exists => true)
    end)
    scope :published_between, ->(starts_at: nil, ends_at: nil) do
      where(
        :published_at.gte => starts_at,
        :published_at.lte => ends_at
      )
    end
    scope :not_scheduled, -> { where(publish_at: nil) }
    scope :scheduled, ->(before: nil, after: nil) do
      criteria = where(:publish_at.gt => Time.current)
      criteria = criteria.where(:publish_at.lte => before) if before.present?
      criteria = criteria.where(:publish_at.gte => after) if after.present?
      criteria
    end
    scope :soonest, -> { scheduled.asc(:publish_at) }
    scope :tomorrow, -> do
      where(
        :publish_at.gte => Time.current.tomorrow.beginning_of_day,
        :publish_at.lte => Time.current.tomorrow.end_of_day
      )
    end

    def self.current
      Thread.current[:current_release]
    end

    def self.current=(release)
      Thread.current[:current_release] = release
    end

    def self.with_current(release)
      previous = current

      new_current = if release.is_a?(Release)
        release
      elsif release.present?
        find(release) rescue nil
      end

      self.current = new_current
      current&.reset_preview
      yield

    ensure
      self.current = previous

      current&.reset_preview
      previous&.reset_preview
    end

    def self.without_current(&block)
      with_current(nil, &block)
    end

    # Gets a list of unscheduled releases
    #
    # @return [Array<Release>]
    #
    def self.unscheduled
      all.and(not_scheduled.selector, not_published.selector).desc(:created_at).to_a
    end

    # Gets a list of unpublished releases sorted by
    # when they will be published.
    #
    # @return [Array<Release>]
    #
    def self.upcoming
      self.unscheduled + scheduled.desc(:publish_at).to_a
    end

    # Get a list of releases published or to be published
    # within a given range
    #
    # @ return [Array<Release>]
    #
    def self.published_within(start_date, end_date)
      results = where(
        :publish_at.gte => start_date.to_time,
        :publish_at.lte => end_date.to_time
      )

      results += where(
        :published_at.gte => start_date.to_time,
        :published_at.lte => end_date.to_time
      )

      results.uniq.sort_by { |r| [r.publish_at || 0, r.published_at || 0] }
    end

    def self.sort_by_publish
      scoped.sort_by { |r| [r.publish_at, r.created_at] }
    end

    def self.schedule_affected_by_changesets(changesets)
      changesets
        .uniq(&:release)
        .reject { |cs| cs.release.blank? }
        .flat_map { |cs| [cs.release] + cs.release.scheduled_after }
        .uniq
    end

    def as_current
      self.class.with_current(self) { yield }
    end

    def scheduled?
      !!publish_at && (persisted? && !publish_at_changed?)
    end

    def published?
      !!published_at
    end

    def upcoming?
      scheduled? || (!scheduled? && !published?)
    end

    def has_changes?
      changesets.present?
    end

    def preview
      @preview ||= Preview.new(self)
    end

    def reset_preview
      @preview = nil
    end

    def scheduled_before
      return [] unless scheduled?
      self.class.scheduled(before: publish_at).ne(id: id).sort_by_publish
    end

    def scheduled_after
      return [] unless scheduled?
      self.class.scheduled(after: publish_at).ne(id: id).sort_by_publish
    end

    def previous
      scheduled_before.last
    end

    def build_undo(attributes = {})
      result = undos.build(attributes)

      result.name ||= I18n.t('workarea.release.undo', name: name)
      result.tags = %w(undo) if result.tags.blank?

      result
    end

    def publish!
      self.published_at = Time.current
      self.publish_at = nil
      save!

      ordered_changesets.each(&:publish!)
      touch_releasables
    end

    def set_publish_job
      self.publish_job_id = Scheduler.schedule(
        worker: PublishRelease,
        at: publish_at,
        args: [id.to_s],
        job_id: publish_job_id
      )
    end

    # Get all statuses of this release.
    #
    # @return [Array<Symbol>]
    #
    def statuses
      calculators = Workarea.config.release_status_calculators.map(&:constantize)
      StatusCalculator.new(calculators, self).results
    end

    # Get changesets ordered based on publish priority set by configuration.
    #
    # @return [Array<Workarea::Release::Changeset>]
    #
    def ordered_changesets
      ordering = Workarea.config.release_changeset_ordering

      changesets.sort_by do |changeset|
        ordering[changeset.releasable_type].presence || 999
      end
    end

    def large?
      changesets.count > Workarea.config.release_large_change_count_threshold
    end

    private

    def publish_at_status
      if !published? && publish_at.present? && publish_at <= Time.current
        errors.add(:publish_at, I18n.t('workarea.errors.messages.must_be_future'))
      end
    end

    def schedule_publish
      set_publish_job if publish_at_changed? && publish_at.present?
    end

    def remove_publish_job
      return if publish_job_id.blank?

      Scheduler.delete(publish_job_id)
      self.publish_job_id = nil
    end

    def touch_releasables
      Sidekiq::Callbacks.disable do
        changesets
          .map(&:releasable_from_document_path)
          .compact
          .uniq
          .each(&:touch)
      end
    end
  end
end
