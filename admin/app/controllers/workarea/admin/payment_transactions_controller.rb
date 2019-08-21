module Workarea
  class Admin::PaymentTransactionsController < Admin::ApplicationController
    required_permissions :orders
    after_action :track_index_filters, only: :index

    def index
      search = Search::AdminPaymentTransactions.new(
        params.merge(autocomplete: request.xhr?)
      )

      @search = Admin::SearchViewModel.new(search, view_model_options)
    end

    def show
      @transaction = Admin::TransactionViewModel.wrap(
        Payment::Transaction.find(params[:id])
      )
    end
  end
end
