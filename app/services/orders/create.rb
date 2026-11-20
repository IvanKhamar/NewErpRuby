module Orders
  # A manual order (by phone or from social networks), like the old site's "Quick order" form.
  #
  # As on the old site: first the order without a status, then its status through the usual status change, so the
  # status log and the status handlers (sewn stock) run. The OpenCart tables are MyISAM and cannot roll back, so
  # the rows are written step by step, the order row first (to get its id).
  class Create < ApplicationService
    Params = Data.define(:firstname, :lastname, :telephone, :email, :instagram, :order_source_id, :status_id,
                         :manager_id, :shipping_code, :shipping_method, :city, :address1, :address2, :house, :flat,
                         :payment_code, :payment_method, :lines, :shipping_cost, :discount, :prepayment, :comment)

    Created = Data.define(:order_id, :warnings, :risk)
    LineRecord = Data.define(:line, :name, :model, :option)

    def initialize(params:, user:)
      @p = params
      @user = user
    end

    def call
      draft = OrderDraft.new(lines: @p.lines, shipping_cost: @p.shipping_cost, discount: @p.discount,
                             prepayment: @p.prepayment)
      draft.validate_customer!(firstname: @p.firstname, telephone: @p.telephone,
                               shipping_method: @p.shipping_method, payment_method: @p.payment_method)
      return failure("Статусу #{@p.status_id} не існує.") unless OrderStatus.exists_with_id?(@p.status_id)
      if @p.order_source_id != 0 && !OrderSource.localized.exists?(order_source_id: @p.order_source_id)
        return failure("Джерела замовлення #{@p.order_source_id} не існує.")
      end

      manager_id = @p.manager_id || @user.id
      return failure("Користувача #{manager_id} не знайдено або його вимкнено.") unless User.active.exists?(manager_id)

      records = line_records(draft.lines)
      # Risk is counted before saving, so the new order does not count itself.
      risk = CustomerRiskCheck.new(telephone: @p.telephone, firstname: @p.firstname, lastname: @p.lastname,
                                   email: @p.email).call
      order = save_order(draft, records)
      OrderManager.create!(order_id: order.id, user_id: manager_id, assigned_by_user_id: @user.id,
                           assigned_at: order.date_added)
      status = ChangeStatus.call(order_id: order.id, status_id: @p.status_id, user: @user, publish: false)
      OrderEvents.created(order_id: order.id, status_id: @p.status_id, manager_id:, source_id: @p.order_source_id,
                          total: draft.total, occurred_at: order.date_added)
      success(Created.new(order_id: order.id, warnings: status.value || [], risk:))
    end

    private

    def line_records(lines)
      products = Product.where(product_id: lines.map(&:product_id).uniq)
                        .includes(:description, option_values: %i[option_description value_description])
                        .index_by(&:id)
      lines.map { |line| line_record(line, products[line.product_id]) }
    end

    def line_record(line, product)
      raise DomainError, "Товару #{line.product_id} не знайдено." if product.nil?

      option = nil
      if line.product_option_value_id
        option = product.option_values.find { |o| o.id == line.product_option_value_id }
        if option.nil?
          raise DomainError, "Товар «#{product.name}» не має такого розміру чи опції (#{line.product_option_value_id})."
        end
      elsif product.option_values.any?
        raise DomainError, "Оберіть розмір чи опцію для товару «#{product.name}»."
      end
      LineRecord.new(line:, name: product.name, model: product.model, option:)
    end

    def save_order(draft, records)
      order = Order.create!(order_attributes(draft))
      records.each { |record| add_line(order, record) }
      add_totals(order, draft)
      order
    end

    # Shop fields (name, currency, country, address format) come from settings NewErp does not have, so they are
    # taken from the latest order of the site, as the reference does.
    def order_attributes(draft)
      template = Order.order(order_id: :desc).first
      now = Time.current
      address = { firstname: text(@p.firstname), lastname: text(@p.lastname), city: text(@p.city),
                  address_1: text(@p.address1), address_2: text(@p.address2),
                  country: template&.shipping_country || "Україна", country_id: template&.shipping_country_id || 220,
                  zone: template&.shipping_zone.to_s, zone_id: template&.shipping_zone_id.to_i,
                  address_format: template&.shipping_address_format.to_s }
      # As on the old site: the payment and the shipping address are the same.
      both = address.flat_map { |key, value| [["payment_#{key}", value], ["shipping_#{key}", value]] }.to_h

      { invoice_prefix: template&.invoice_prefix.to_s, store_id: template&.store_id.to_i,
        store_name: template&.store_name.to_s, store_url: template&.store_url.to_s,
        firstname: text(@p.firstname), lastname: text(@p.lastname), email: text(@p.email),
        telephone: text(@p.telephone), instagram: text(@p.instagram), custom_field: "[]",
        payment_custom_field: "[]", shipping_custom_field: "[]",
        payment_method: text(@p.payment_method), payment_code: text(@p.payment_code),
        shipping_method: text(@p.shipping_method), shipping_code: text(@p.shipping_code),
        shipping_house: text(@p.house), shipping_flat: text(@p.flat), comment: text(@p.comment),
        total: draft.total, prepayment: draft.prepayment, order_status_id: 0, order_source_id: @p.order_source_id,
        language_id: template&.language_id || ErpSettings.language_id, currency_id: template&.currency_id.to_i,
        currency_code: template&.currency_code || "UAH", currency_value: template&.currency_value || 1,
        user_agent: "NewErp", date_added: now, date_modified: now }.merge(both)
    end

    def add_line(order, record)
      product = OrderProduct.create!(order_id: order.id, product_id: record.line.product_id, name: record.name,
                                     model: record.model, quantity: record.line.quantity, price: record.line.price,
                                     total: record.line.total)
      return if record.option.nil?

      OrderOption.create!(order_id: order.id, order_product_id: product.id,
                          product_option_id: record.option.product_option_id,
                          product_option_value_id: record.option.id, name: record.option.option_name,
                          value: record.option.value_name, type: "radio") # as the size rows the site writes
    end

    def add_totals(order, draft)
      totals = [["sub_total", "Сума", draft.sub_total], ["shipping", order.shipping_method, draft.shipping_cost]]
      totals << ["coupon", "Знижка", -draft.discount] if draft.discount.positive?
      totals << ["total", "Всього", draft.total]
      totals.each_with_index do |(code, title, value), sort_order|
        OrderTotal.create!(order_id: order.id, code:, title:, value:, sort_order:)
      end
    end

    def text(value) = value.to_s.strip
  end
end
