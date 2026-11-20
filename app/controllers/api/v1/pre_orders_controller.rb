module Api
  module V1
    # Size pre-orders: a limit and an expected date per product size (Admin, Manager).
    class PreOrdersController < BaseController
      LIST_LIMIT = 200

      before_action -> { authorize :orders, :manage? }

      def index
        sizes = ProductOptionValue.with_product_names.includes(:value_description)
                                  .order("d.name", :product_id, :product_option_value_id).limit(LIST_LIMIT)
        search = params[:search].to_s.strip
        if search.present?
          sizes = sizes.where("d.name LIKE :q OR dd_product.model LIKE :q",
                              q: "%#{ProductOptionValue.sanitize_sql_like(search)}%")
        end
        sizes = sizes.where("pre_order_quantity > 0") if bool_param(:onlyWithQuota)
        render_json PreOrderSerializer, sizes
      end

      def update
        quota = params[:quota]
        raise InvalidParameter, "Некоректні параметри запиту: quota." unless quota.is_a?(Integer)
        unless quota.between?(0, ProductOptionValue::MAX_QUOTA)
          raise DomainError, "Ліміт передзамовлення — від 0 до #{ProductOptionValue::MAX_QUOTA} штук."
        end

        size = ProductOptionValue.find_by(product_option_value_id: params[:id])
        return render_problem(404, ProblemDetails::NOT_FOUND, "Розміру #{params[:id]} не знайдено.") if size.nil?

        size.update!(pre_order_quantity: quota, date_available: date_param(:dateAvailable))
        head :no_content
      end

      def settle
        render json: { sizes: PreOrders::Settle.call.value }
      end
    end
  end
end
