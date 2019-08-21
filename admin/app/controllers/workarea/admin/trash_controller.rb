module Workarea
  module Admin
    class TrashController < Admin::ApplicationController
      before_action :check_restore_authorization, only: :restore

      def index
        @entries = Mongoid::AuditLog::Entry
                    .all
                    .destroys
                    .where(restored: false)
                    .desc(:created_at)
                    .page(params[:page])
      end

      def restore
        entry = Mongoid::AuditLog::Entry.find(params[:id])
        entry.restore!

        flash[:success] = t('workarea.admin.trash.flash_messages.success')
        redirect_to(
          if entry.audited.is_a?(Content::Block)
            edit_content_path(entry.root)
          elsif entry.audited.is_a?(Navigation::Taxon)
            navigation_taxons_path(taxon_ids: entry.audited.parent_ids)
          elsif entry.audited.is_a?(Comment)
            commentable_comments_path(entry.root.commentable.to_global_id)
          else
            polymorphic_path(entry.root)
          end
        )

      rescue Mongoid::Errors::Validations => e
        flash[:error] = e.document.errors.to_a.to_sentence
        redirect_back fallback_location: trash_index_path
      rescue Mongoid::AuditLog::Restore::InvalidRestore
        flash[:error] = t('workarea.admin.trash.flash_messages.error')
        redirect_back fallback_location: trash_index_path
      end

      private

      def check_restore_authorization
        unless current_user.can_restore?
          flash[:error] = t('workarea.admin.trash.flash_messages.unauthorized')
          redirect_back(fallback_location: root_path) && (return false)
        end
      end
    end
  end
end
