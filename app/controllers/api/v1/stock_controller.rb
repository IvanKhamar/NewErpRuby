module Api
  module V1
    # Consumables stock: items, receipts and uses with the movement log (Admin and Storekeeper).
    class StockController < BaseController
      before_action -> { authorize :stock, :manage? }

      def categories
        render_json StockSerializers::Category, StockCategory.sorted
      end

      def items
        items = StockItem.active.includes(:category, :supplier).sorted
        items = items.in_category(int_param(:categoryId)) if params[:categoryId].present?
        items = items.below_minimum if bool_param(:belowMinimumOnly)
        render_json StockSerializers::Item, items
      end

      def show
        item = StockItem.active.includes(:category, :supplier).find_by(item_id: params[:id])
        return render_problem(404, ProblemDetails::NOT_FOUND, "Позицію складу #{params[:id]} не знайдено.") if item.nil?

        render_json StockSerializers::Item, item
      end

      # A new item starts with zero quantity: stock comes only through adjustments, so it is always in the log.
      def create
        p = params.permit(:categoryId, :supplierId, :name, :unit, :minQuantity, :usedFor, :price)
        require_reference(StockCategory, p[:categoryId], "Категорії")
        require_reference(StockSupplier, p[:supplierId], "Постачальника")
        item = StockItem.new(stock: 0, status: true).describe(
          category_id: p[:categoryId], supplier_id: p[:supplierId], name: p[:name], unit: p[:unit],
          used_for: p[:usedFor], min_quantity: decimal_value(p[:minQuantity], "minQuantity"),
          price: decimal_value(p[:price], "price")
        )
        item.save!
        render json: { id: item.id }, status: :created
      end

      def adjust
        p = params.permit(:delta, :reason)
        result = Stock::Adjust.call(item_id: params[:id].to_i, delta: decimal_value(p[:delta], "delta"),
                                    reason: p[:reason], user: Current.user)
        return render_failure(result) unless result.success?

        render_json StockSerializers::Movement, result.value
      end

      def movements
        item = StockItem.active.find_by(item_id: params[:id])
        return render_problem(404, ProblemDetails::NOT_FOUND, "Позицію складу #{params[:id]} не знайдено.") if item.nil?

        render_json StockSerializers::Movement, item.movements
      end

      private

      def require_reference(model, id, what)
        return if id.nil? || model.exists?(id)

        raise DomainError, "#{what} #{id} не існує."
      end
    end
  end
end
