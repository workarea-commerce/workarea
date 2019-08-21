module Workarea
  class Admin::NavigationTaxonsController < Admin::ApplicationController
    required_permissions :store

    before_action :find_taxon, except: [:index, :new, :create, :select]
    before_action :new_taxon, only: [:index, :new, :create]

    def index
      @roots = if params[:taxon_ids].present?
                 Navigation::Taxon
                   .find(params[:taxon_ids])
                   .sort_by(&:depth)
               else
                 [Navigation::Taxon.root]
               end
    end

    def new
      @parent = Navigation::Taxon.find(params[:parent_id])
    end

    def create
      SetNavigable.new(@taxon, params).set

      if @taxon.save
        @taxon.move_to_position(params[:position]) if params[:position].present?

        flash[:success] = t('workarea.admin.navigation_taxons.flash_messages.created')
        redirect_to navigation_taxons_path(taxon_ids: @taxon.parent_ids)
      else
        flash[:error] = t('workarea.admin.navigation_taxons.flash_messages.created_error')
        @parent = Navigation::Taxon.find(params[:parent_id])
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      SetNavigable.new(@taxon, params).set

      if @taxon.update_attributes(params[:taxon])
        flash[:success] = t('workarea.admin.navigation_taxons.flash_messages.updated')
        redirect_to navigation_taxons_path(taxon_ids: @taxon.parent_ids)
      else
        flash[:error] = t('workarea.admin.navigation_taxons.flash_messages.changes_error')
        render :edit, status: :unprocessable_entity
      end
    end

    def select
      if params[:id].present?
        @taxon = Navigation::Taxon.find(params[:id])
      else
        @taxon = Workarea::Navigation::Taxon.root
      end

      render partial: 'select', locals: { taxon: @taxon }
    end

    def insert
      taxon = Navigation::Taxon.new(params[:taxon])
      render partial: 'insert', locals: { parent: @taxon, taxon: taxon }
    end

    def children; end

    def move
      other = Navigation::Taxon.find(params[:other_id])

      if params[:direction] == 'above'
        @taxon.move_above(other)
      elsif params[:direction] == 'below'
        @taxon.move_below(other)
      else
        @taxon.parent = other
        @taxon.save!
      end

      head 200
    end

    def destroy
      if @taxon.destroy
        flash[:success] = t('workarea.admin.navigation_taxons.flash_messages.removed')
      else
        flash[:error] = @taxon.errors.to_a.to_sentence
      end

      redirect_to navigation_taxons_path(taxon_ids: @taxon.parent_ids)
    end

    private

    def new_taxon
      @taxon = Navigation::Taxon.new(params[:taxon])
      @taxon.parent_id = params[:parent_id] if params[:parent_id].present?
    end

    def find_taxon
      @taxon = Navigation::Taxon.find(params[:id])
    end
  end
end
