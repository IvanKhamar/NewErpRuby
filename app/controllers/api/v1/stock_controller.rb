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

      MAX_SHEET_BYTES = 5 * 1024 * 1024
      XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze

      # An Excel sheet to count on, with an empty "Фактично" column.
      def stocktaking_sheet
        sheet = Stock::Stocktaking.sheet(category_id: int_param(:categoryId), warehouse_id: int_param(:warehouseId))
        send_data sheet, filename: "inventaryzatsiia.xlsx", type: XLSX
      end

      # What the counted sheet (the raw request body, as in the reference) would change; writes nothing.
      def stocktaking_preview
        body = request.body.read(MAX_SHEET_BYTES + 1).to_s
        raise DomainError, "Файл більший за #{MAX_SHEET_BYTES / 1024 / 1024} МБ." if body.bytesize > MAX_SHEET_BYTES

        counts, errors = Tempfile.create(%w[stocktaking .xlsx], binmode: true) do |file|
          file.write(body)
          file.flush
          Stock::Stocktaking.parse(file.path)
        end
        render json: preview_json(counts, errors)
      end

      def apply_stocktaking
        p = params.permit(:comment, :warehouseId, counts: %i[itemId actual])
        counts = Array(p[:counts]).map do |c|
          Stock::Stocktaking::Count.new(item_id: integer_value(c[:itemId], "counts.itemId"),
                                        actual: decimal_value(c[:actual], "counts.actual"))
        end
        result = Stock::ApplyStocktaking.call(counts:, comment: p[:comment], user: Current.user,
                                              warehouse_id: optional_int(p[:warehouseId], "warehouseId"))
        return render_failure(result) unless result.success?

        render json: { counted: result.value.counted, changed: result.value.changed, value: result.value.value.to_f }
      end

      private

      def preview_json(counts, errors)
        items = StockItem.active.where(item_id: counts.map(&:item_id)).index_by(&:id)
        booked = Stock::Stocktaking.booked(items.values, int_param(:warehouseId))
        lines = counts.filter_map do |count|
          item = items[count.item_id]
          next errors << "Позиції #{count.item_id} немає на складі." if item.nil?

          Stock::Stocktaking::Line.new(item_id: item.id, name: item.name, unit: item.unit, booked: booked[item.id],
                                       actual: count.actual)
        end
        { lines: lines.sort_by { |l| UkrainianSort.key(l.name) }.map do |l|
          { itemId: l.item_id, name: l.name, unit: l.unit, booked: l.booked.to_f, actual: l.actual.to_f,
            difference: l.difference.to_f }
        end, errors: }
      end

      def optional_int(value, name) = value.nil? ? nil : integer_value(value, name)

      def require_reference(model, id, what)
        return if id.nil? || model.exists?(id)

        raise DomainError, "#{what} #{id} не існує."
      end
    end
  end
end
