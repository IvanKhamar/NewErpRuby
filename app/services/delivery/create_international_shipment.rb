module Delivery
  # A Nova Post International waybill for an order going abroad. Checks the customs data first (all missing fields
  # in one message, like the reference), builds the request body field for field as the old site did, and keeps
  # the waybill as a delivery document with carrier "international".
  class CreateInternationalShipment < ApplicationService
    REGION_REQUIRED = %w[US IE CA].freeze # the API needs a state or region for these countries
    TERMS = { incoterm: "DAP", export_reason: "Selling", payer_fees_customs: "Recipient", cargo_category: "parcel",
              delivery_type: nil, parcel_description: "Printed apparel / merchandise" }.freeze

    Recipient = Data.define(:first_name, :last_name, :phone, :email, :country_code, :region, :city, :street,
                            :building, :flat, :post_code)
    Item = Data.define(:name, :name_eng, :hs_code, :weight_grams, :amount, :cost)
    Seat = Data.define(:weight, :width, :length, :height) # kg and cm, as people type them

    def initialize(order_id:, recipient:, items:, seats:, declared_cost:, currency:, terms: {},
                   client: NovaPost::InternationalClient.build)
      @order_id = order_id
      @recipient = recipient
      @items = items
      @seats = seats
      @declared_cost = declared_cost
      @currency = currency.to_s.strip.upcase.presence || "UAH"
      @terms = TERMS.merge(terms.compact_blank)
      @client = client
    end

    def call
      return not_found("Замовлення #{@order_id} не знайдено.") unless Order.exists?(order_id: @order_id)

      missing = missing_fields
      return failure("Не заповнені або некоректні поля: #{missing.join(', ')}.") if missing.any?

      created = @client.create(payload)
      document = DeliveryDocument.create!(order_id: @order_id, carrier: DeliveryDocument::INTERNATIONAL,
                                          ref: created.ref, number: created.number,
                                          cost: created.cost || @declared_cost, date_created: Time.current)
      success(document)
    rescue NovaPost::InternationalClient::Error => e
      failure(e.message)
    end

    private

    def missing_fields
      r = @recipient
      missing = { "Ім'я" => r.first_name, "Телефон" => r.phone, "Населений пункт" => r.city, "Вулиця" => r.street,
                  "Будинок" => r.building, "Індекс" => r.post_code }.select { |_, value| value.blank? }.keys
      country = r.country_code.to_s.strip.upcase
      missing << "Країна отримувача (не Україна)" unless country.match?(/\A[A-Z]{2}\z/) && country != "UA"
      if REGION_REQUIRED.include?(country) && r.region.blank?
        missing << "Штат/область (обов'язково для США, Ірландії, Канади)"
      end
      missing << "товари в замовленні" if @items.empty?
      @items.each { |item| missing.concat(item_problems(item)) }
      missing << "декларована вартість" unless @declared_cost&.positive?
      missing << "параметри місця відправлення (розміри/вага)" if @seats.empty?
      missing
    end

    def item_problems(item)
      label = item.name.presence || "товар"
      [("код УКТЗЕД (#{label})" if item.hs_code.to_s.gsub(/\D/, "").empty?),
       ("англійська назва товару (#{label})" if item.name_eng.blank?),
       ("вага товару в грамах (#{label})" unless item.weight_grams.to_i.positive?)].compact
    end

    def payload
      body = {
        status: "ReadyToShip", clientOrder: @order_id.to_s, note: "Vidro order ##{@order_id}", payerType: "Sender",
        invoice: { incoterm: @terms[:incoterm], exportReason: @terms[:export_reason], cost: @declared_cost.to_f,
                   currency: @currency, payerFeesCustoms: @terms[:payer_fees_customs], items: invoice_items },
        parcels:, sender: Sender.from_env, recipient: recipient_body
      }
      body[:deliveryType] = @terms[:delivery_type] if @terms[:delivery_type]
      body
    end

    def invoice_items
      @items.map do |i|
        { hsCode: i.hs_code.to_s.gsub(/\D/, ""), name: i.name.to_s.strip, nameEng: i.name_eng.to_s.strip,
          actualWeight: i.weight_grams, measurementCode: "pieces",
          amount: (i.amount&.positive? ? i.amount : 1).to_f, cost: (i.cost || 0).to_f }
      end
    end

    # As the old site counted seats: cm × 10 = mm, the declared cost split evenly as insurance, and a single seat
    # weighs what its items weigh (several seats: each its own weight in kg × 1000).
    def parcels
      insurance = (@declared_cost / @seats.size).round(2, half: :up)
      items_weight = @items.sum { |i| i.weight_grams.to_i }
      @seats.each_with_index.map do |seat, index|
        { cargoCategory: @terms[:cargo_category], parcelDescription: @terms[:parcel_description],
          insuranceCost: insurance.to_f, rowNumber: index + 1, width: mm(seat.width), length: mm(seat.length),
          height: mm(seat.height),
          actualWeight: @seats.one? ? items_weight : (seat.weight * 1000).round(half: :up).to_i }
      end
    end

    def mm(centimeters) = ((centimeters.to_d.positive? ? centimeters.to_d : 1) * 10).round(half: :up).to_i

    def recipient_body
      r = @recipient
      { phone: r.phone.to_s.gsub(/\D/, ""), email: r.email.to_s.strip,
        name: "#{r.first_name.to_s.strip} #{r.last_name.to_s.strip}".strip,
        countryCode: r.country_code.to_s.strip.upcase,
        addressParts: { city: r.city.to_s.strip, region: r.region.to_s.strip, street: r.street.to_s.strip,
                        postCode: r.post_code.to_s.strip, building: r.building.to_s.strip, flat: r.flat.to_s.strip } }
    end

    # The shop as the sender, from NEWERP_NOVA_POST_SENDER (JSON with name, phone, email, city, street, postCode,
    # building, flat, companyTin, companyName). Business contacts, not secrets, but kept out of the code all the same.
    module Sender
      module_function

      def from_env
        s = JSON.parse(ENV.fetch("NEWERP_NOVA_POST_SENDER", "{}"))
        address = { city: s["city"].to_s, street: s["street"].to_s, postCode: s["postCode"].to_s,
                    building: s["building"].to_s, flat: s["flat"].to_s }
        sender = { companyTin: s["companyTin"].to_s, companyName: s["companyName"].to_s,
                   phone: s["phone"].to_s.gsub(/\D/, ""), email: s["email"].to_s, name: s["name"].to_s,
                   countryCode: "UA", addressParts: address }
        # Nova Post support told the old site: a company sender also needs registrationAddressParts.
        sender[:registrationAddressParts] = address.merge(region: "", note: "") if s["companyTin"].present?
        sender
      end
    end
  end
end
