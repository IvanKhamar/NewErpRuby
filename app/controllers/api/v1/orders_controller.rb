module Api
  module V1
    # Orders: list, card, manual orders, status changes (Admin and Manager).
    class OrdersController < BaseController
      MAX_PAGE_SIZE = 100

      before_action -> { authorize :orders, :manage? }

      def index
        page = [int_param(:page, default: 1), 1].max
        page_size = int_param(:pageSize, default: 20).clamp(1, MAX_PAGE_SIZE)
        orders = filtered_orders
        items = orders.includes(:status, :source, :manager).newest_first.offset((page - 1) * page_size).limit(page_size)
        render json: PagedResultSerializer.new(items:, page:, page_size:, total_count: orders.count,
                                               item_serializer: OrderSerializers::ListItem).serialize
      end

      def show
        order = Order.includes(:status, :source, :manager, :products, status_logs: %i[new_status user])
                     .find_by(order_id: params[:id])
        return render_problem(404, "Not Found") if order.nil? # the reference answers this one in English

        render_json OrderSerializers::Details, order
      end

      def statuses
        render_json OrderSerializers::Status, OrderStatus.localized.order(:order_status_id)
      end

      def sources
        sources = OrderSource.localized.order(:order_source_id).map do |s|
          LookupItem.new(id: s.order_source_id, name: s.name)
        end
        render_json LookupItemSerializer, sources
      end

      # Whom an order can be assigned to: active employees, in Ukrainian alphabetical order.
      def managers
        managers = User.active.map { |u| LookupItem.new(id: u.id, name: u.full_name) }
        render_json(LookupItemSerializer, managers.sort_by { |m| UkrainianSort.key(m.name) })
      end

      def create
        result = Orders::Create.call(params: create_params, user: Current.user)
        return render_failure(result) unless result.success?

        render_json OrderSerializers::CreateResult, result.value, status: :created
      end

      def change_status
        status_id = integer_value(params[:statusId], "statusId")
        result = Orders::ChangeStatus.call(order_id: params[:id].to_i, status_id:, user: Current.user)
        return render_failure(result) unless result.success?

        render json: { warnings: result.value }
      end

      def credits
        credits = Orders::Reward.credits(params[:id].to_i)
        return render_problem(404, ProblemDetails::NOT_FOUND, "Замовлення #{params[:id]} не знайдено.") if credits.nil?

        render_json OrderSerializers::Credits, credits
      end

      def add_reward = change_reward(:add)
      def remove_reward = change_reward(:remove)

      private

      def filtered_orders
        orders = Order.placed.search(params[:search])
        orders = orders.with_status(int_param(:statusId)) if params[:statusId].present?
        orders = orders.from_source(int_param(:sourceId)) if params[:sourceId].present?
        orders = orders.managed_by(int_param(:managerId)) if params[:managerId].present?
        orders = orders.added_from(date_param(:from)) if params[:from].present?
        orders = orders.added_to(date_param(:to)) if params[:to].present?
        orders
      end

      def change_reward(action)
        result = Orders::Reward.call(order_id: params[:id].to_i, action:, user: Current.user)
        return render_failure(result) unless result.success?

        render_json OrderSerializers::Credits, result.value
      end

      # Strong parameters: only the fields of CreateOrderRequest in the contract are read.
      def create_params
        p = params.permit(:firstname, :lastname, :telephone, :email, :instagram, :orderSourceId, :statusId,
                          :managerId, :shippingCode, :shippingMethod, :city, :address1, :address2, :house, :flat,
                          :paymentCode, :paymentMethod, :shippingCost, :discount, :prepayment, :comment,
                          lines: %i[productId productOptionValueId quantity price])
        Orders::Create::Params.new(
          firstname: p[:firstname], lastname: p[:lastname], telephone: p[:telephone], email: p[:email],
          instagram: p[:instagram], order_source_id: integer_value(p[:orderSourceId], "orderSourceId"),
          status_id: integer_value(p[:statusId], "statusId"),
          manager_id: p[:managerId] && integer_value(p[:managerId], "managerId"),
          shipping_code: p[:shippingCode], shipping_method: p[:shippingMethod], city: p[:city],
          address1: p[:address1], address2: p[:address2], house: p[:house], flat: p[:flat],
          payment_code: p[:paymentCode], payment_method: p[:paymentMethod], comment: p[:comment],
          lines: Array(p[:lines]).map { |line| draft_line(line) },
          shipping_cost: decimal_value(p[:shippingCost], "shippingCost"),
          discount: decimal_value(p[:discount], "discount"), prepayment: decimal_value(p[:prepayment], "prepayment")
        )
      end

      def draft_line(line)
        OrderDraft::Line.new(
          product_id: integer_value(line[:productId], "lines.productId"),
          product_option_value_id: line[:productOptionValueId] && integer_value(line[:productOptionValueId],
                                                                                "lines.productOptionValueId"),
          quantity: integer_value(line[:quantity], "lines.quantity"),
          price: decimal_value(line[:price], "lines.price")
        )
      end
    end
  end
end
