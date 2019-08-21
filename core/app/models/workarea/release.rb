module Workarea
  class Release
    include ApplicationDocument
    include Mongoid::Document::Taggable
    include Commentable

    field :name, type: String
    field :publish_at, type: Time
    field :published_at, type: Time
    field :publish_job_id, type: String
    field :undo_at, type: Time
    field :undone_at, type: Time
    field :undo_job_id, type: String

    has_many :changesets, class_name: 'Workarea::Release::Changeset'

    index({ publish_at: 1 })
    index({ published_at: 1 })
    index({ undo_at: 1 })
    index({ undone_at: 1 })

    validates :name, presence: true
    validate :publish_at_status
    validate :undoable_release, if: :undo_at?

    before_save :remove_publish_job, if: Proc.new { |r| r.publish_at.blank? }
    before_save :remove_undo_job, if: Proc.new { |r| r.undo_at.blank? }
    before_save :schedule_publish
    before_save :schedule_undo
    before_destroy :remove_publish_job
    before_destroy :remove_undo_job

    scope :not_published, (lambda do
      any_of({ :published_at.exists => false }, { published_at: nil })
    end)
    scope :published, (lambda do
      where(:published_at.exists => true)
    end)
    scope :not_scheduled, (lambda do
      any_of({ :publish_at.exists => false }, { publish_at: nil })
    end)
    scope :scheduled, -> { where(:publish_at.gt => Time.current) }
    scope :to_undo, -> { where(:undo_at.gt => Time.current) }
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

    def self.with_current(release_id, &block)
      previous = current
      self.current = release_id.blank? ? nil : find(release_id) rescue nil

      return_value = block.call

    ensure
      self.current = previous
      return_value
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

    # Get a list of releases undone or to be undone
    # within a given range
    #
    # @ return [Array<Release>]
    #
    def self.undone_within(start_date, end_date)
      results = where(
        :undo_at.gte => start_date.to_time,
        :undo_at.lte => end_date.to_time
      )

      results += where(
        :undone_at.gte => start_date.to_time,
        :undone_at.lte => end_date.to_time
      )

      results.uniq.sort_by { |r| [r.undo_at || 0, r.undone_at || 0] }
    end

    def as_current
      self.class.with_current(id) do
        yield
      end
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

    def undone?
      !!undone_at
    end

    def has_changes?
      changesets.present?
    end

    def publish!
      self.published_at = Time.current
      self.undone_at = nil
      self.publish_at = nil
      save!

      changesets.each(&:publish!)
    end

    def undo!
      self.undo_at = nil if undo_at.present? && undo_at >= Time.current
      self.undone_at = Time.current
      save!

      changesets.each(&:undo!)
    end

    def set_publish_job
      self.publish_job_id = Scheduler.schedule(
        worker: PublishRelease,
        at: publish_at,
        args: [id.to_s],
        job_id: publish_job_id
      )
    end

    def set_undo_job
      self.undo_job_id = Scheduler.schedule(
        worker: UndoRelease,
        at: undo_at,
        args: [id.to_s],
        job_id: undo_job_id
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

    private

    def publish_at_status
      if !published? && publish_at.present? && publish_at <= Time.current
        errors.add(:publish_at, I18n.t('workarea.errors.messages.must_be_future'))
      end
    end

    def schedule_publish
      set_publish_job if publish_at_changed? && publish_at.present?
    end

    def schedule_undo
      set_undo_job if undo_at_changed? && undo_at.present?
    end

    def remove_publish_job
      return if publish_job_id.blank?

      Scheduler.delete(publish_job_id)
      self.publish_job_id = nil
    end

    def remove_undo_job
      return if undo_job_id.blank?

      Scheduler.delete(undo_job_id)
      self.undo_job_id = nil
    end

    def undoable_release
      unless publish_at.present? || published_at.present?
        errors.add(:undo_at, I18n.t('workarea.errors.messages.undo_unpublished_release'))
      end
    end
  end
end
