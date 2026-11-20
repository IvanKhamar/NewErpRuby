module Api
  module V1
    # Production: garment models, their BOMs, cutting and sewing (Admin and Storekeeper).
    class ProductionController < BaseController
      before_action -> { authorize :production, :manage? }

      def models
        models = ProductionModel.active.includes(:sizes).sorted
        models = models.of_type(params[:type]) if params[:type].present?
        models = models.to_a
        models = models.select { |m| m.total_sewn < m.min_total } if bool_param(:belowMinimumOnly)
        render_json ProductionSerializers::Summary, models
      end

      def show
        model = ProductionModel.active
                               .includes(:sizes, :product_links, :category_links,
                                         { components: [:stocks, { bom_lines: :item }] },
                                         { sewn_bom_lines: %i[component item] })
                               .find_by(production_id: params[:id])
        return render_problem(404, ProblemDetails::NOT_FOUND, "Модель #{params[:id]} не знайдено.") if model.nil?

        render_json ProductionSerializers::Model, model
      end

      # POST /production/models/{id}/cut | to-sewing | sewn | ship
      def operation
        p = params.permit(:comment, :warehouseId, quantities: %i[sizeId quantity])
        rows = Array(p[:quantities]).map do |row|
          Production::RecordOperation::Row.new(size_id: integer_value(row[:sizeId], "quantities.sizeId"),
                                               quantity: decimal_value(row[:quantity], "quantities.quantity"))
        end
        result = Production::RecordOperation.call(
          production_id: params[:id].to_i, operation: params[:operation], rows:, comment: p[:comment],
          warehouse_id: p[:warehouseId] && integer_value(p[:warehouseId], "warehouseId"), user: Current.user
        )
        return render_failure(result) unless result.success?

        render_json ProductionSerializers::OperationResult, result.value
      end

      def component_bom
        rows = bom_rows { |row| [nil, integer_value(row[:itemId], "rows.itemId")] }
        render_bom_result Production::SetBom.call(kind: :component, id: params[:id].to_i, rows:)
      end

      def sewn_bom
        rows = bom_rows do |row|
          [row[:componentId] && integer_value(row[:componentId], "rows.componentId"),
           row[:itemId] && integer_value(row[:itemId], "rows.itemId")]
        end
        render_bom_result Production::SetBom.call(kind: :sewn, id: params[:id].to_i, rows:)
      end

      private

      def bom_rows
        p = params.permit(rows: %i[sizeId componentId itemId qtyPerUnit])
        Array(p[:rows]).map do |row|
          component_id, item_id = yield(row)
          Production::SetBom::Row.new(size_id: row[:sizeId] && integer_value(row[:sizeId], "rows.sizeId"),
                                      component_id:, item_id:,
                                      qty_per_unit: decimal_value(row[:qtyPerUnit], "rows.qtyPerUnit"))
        end
      end

      def render_bom_result(result)
        return render_failure(result) unless result.success?

        head :no_content
      end
    end
  end
end
