module Admin
  # Orders list and card with the status change (Admin, Manager).
  class OrdersController < BaseController
    PAGE_SIZE = 25

    before_action -> { authorize :orders, :manage? }

    def index
      @statuses = OrderStatus.localized.order(:order_status_id)
      @page = [params[:page].to_i, 1].max
      orders = Order.placed.search(params[:search])
      orders = orders.with_status(params[:status_id].to_i) if params[:status_id].present?
      @total = orders.count
      @orders = orders.includes(:status, :manager).newest_first.offset((@page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
    end

    def show
      @order = Order.includes(:status, :source, :manager, :products, status_logs: %i[new_status user])
                    .find(params.expect(:id))
      @statuses = OrderStatus.localized.order(:order_status_id)
    end

    def status
      result = Orders::ChangeStatus.call(order_id: params[:id].to_i, status_id: params.require(:status_id).to_i,
                                         user: Current.user)
      flash_result(result, notice: "Статус змінено.")
      redirect_to admin_order_path(params[:id]), status: :see_other
    end
  end
end
