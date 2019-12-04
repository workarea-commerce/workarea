module Workarea
  module Admin
    class ContentViewModel < ApplicationViewModel
      include CommentableViewModel

      def contentable
        return if system?

        @contentable ||= ApplicationController.wrap_in_view_model(
          model.contentable,
          options
        )
      end

      # Whether to show fields that are used in the <head> of the page
      # on which the content is rendered, like title and  meta tags.
      #
      # @return [Boolean]
      #
      def show_advanced?
        (!system? && !contentable.is_a?(Navigation::Menu)) || home_page?
      end

      # The list of available areas blocks can be added to. Specific to this
      # type of content. Intended to be configured as part of customizing the
      # system.
      #
      # @return [Array<String>]
      #
      def areas
        Workarea.config.content_areas[model.slug] ||
          Workarea.config.content_areas[contentable_template] ||
          Workarea.config.content_areas['generic']
      end

      # List of customized content blocks available for
      # reuse in a content area.
      #
      # @return [Array<Content::Preset>]
      #
      def presets
        @presets ||= Content::Preset.all.to_a
      end

      # Whether to show area selection for this content, not necessary if there
      # is only one area.
      #
      # @return [Boolean]
      #
      def show_areas?
        areas.many?
      end

      # Options for use in the area select tag.
      #
      # @return [Array<Array<String, String>>]
      #
      def area_options
        areas.map { |area| [area.titleize, area] }
      end

      # The area currently editing blocks for.
      #
      # @return [String]
      #
      def current_area
        options[:area_id].presence || areas.first
      end

      # The current set of blocks to display for editing. Matching the
      # {#current_area} and active.
      #
      # @return [Array<Workarea::Content::Block>]
      #
      def current_blocks
        model.blocks_for(current_area).select(&:active?).select(&:persisted?)
      end

      # Whether there is a new block being created.
      #
      # @return [Boolean]
      #
      def new_block?(at: nil)
        return false unless options[:new_block].present?
        at.blank? || new_block.position == at
      end

      # HACK
      #
      # This method returns whether we can reliably determine the position of
      # the new block being added. This can be very difficult to generate due to
      # possible resorting of blocks within a release combined with release
      # previewing based on publishing time.
      #
      # The only time this has caused an issue in use is adding a new first
      # block, so this is used in combination with the above `new_block?` to
      # decide whether to render the first block.
      #
      # @return [Boolean]
      #
      def ambiguous_new_block_position?
        return false unless options[:new_block].present?

        known_positions = [0] + current_blocks.map { |b| b.position + 1 }
        known_positions.exclude?(new_block.position)
      end

      # An instance of the new block being created.
      #
      # @return [Workarea::Content::Block]
      #
      def new_block
        @new_block ||= model.blocks.build(
          options.fetch(:new_block, {}).merge(data: new_block_defaults)
        )
      end

      # A block draft instance that represents the supplied state of the new
      # block. Used for rendering the initial preview.
      #
      # @return [Workarea::Content::BlockDraft]
      #
      def new_block_draft
        @new_block_draft ||=
          Content::BlockDraft.create!(
            content_id: model.id,
            type_id: new_block.type_id,
            data: new_block.data,
            area: current_area
          )
      end

      def new_block_defaults
        if options[:preset_id].present?
          Content::Preset.find(options[:preset_id]).data
        else
          Content::BlockType.find(
            options.dig(:new_block, :type_id).to_sym
          ).defaults
        end
      end

      def timeline
        @timeline ||= TimelineViewModel.wrap(model)
      end

      def contentable_template
        contentable.try(:template)
      end

      def open_graph_asset
        @open_graph_asset ||=
          if model.open_graph_asset_id.present?
            Content::Asset.find(model.open_graph_asset_id)
          elsif (og_default = Content::Asset.open_graph_default).present?
            og_default
          else
            Content::Asset.open_graph_placeholder
          end
      rescue Mongoid::Errors::DocumentNotFound
        @open_graph_asset = Content::Asset.open_graph_placeholder
      end
    end
  end
end
