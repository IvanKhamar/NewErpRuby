module Admin
  # Consumables: the list and an item with its movement log and the receipt/use form (Admin, Storekeeper).
  class StockItemsController < BaseController
    before_action -> { authorize :stock, :manage? }

    def index
      @items = StockItem.active.includes(:category).sorted
      @items = @items.below_minimum if params[:below_minimum] == "1"
    end

    def show
      @item = StockItem.active.includes(:category, :supplier).find(params.expect(:id))
      @movements = @item.movements.limit(50)
    end

    def adjustments
      delta = BigDecimal(params.require(:delta).to_s.tr(",", "."))
      result = Stock::Adjust.call(item_id: params[:id].to_i, delta:, reason: params[:reason], user: Current.user)
      flash_result(result, notice: "Залишок змінено.")
      redirect_to admin_stock_item_path(params[:id]), status: :see_other
    rescue ArgumentError
      redirect_to admin_stock_item_path(params[:id]), alert: "Кількість має бути числом.", status: :see_other
    end
  end
end
