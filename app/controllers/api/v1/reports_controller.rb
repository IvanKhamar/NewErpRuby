module Api
  module V1
    # Reports (Admin, Manager).
    class ReportsController < BaseController
      before_action -> { authorize :orders, :manage? }

      def sales
        result = Reports::Sales.call(from: date_param(:from), to: date_param(:to), status_id: int_param(:statusId),
                                     group: params.fetch(:group, "Week"))
        return render_failure(result) unless result.success?

        report = result.value
        render json: {
          from: report.from.iso8601, to: report.to.iso8601, orders: report.orders, products: report.products,
          total: report.total.to_f,
          rows: report.rows.map do |row|
            { start: row.start.iso8601, end: row.finish.iso8601, orders: row.orders, products: row.products,
              total: row.total.to_f }
          end
        }
      end
    end
  end
end
