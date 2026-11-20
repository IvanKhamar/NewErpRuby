module Api
  module V1
    # What an order sends outside: SMS to the customer and the international waybill (Admin, Manager).
    class OrderIntegrationsController < BaseController
      before_action -> { authorize :orders, :manage? }

      def sms_history
        render_json IntegrationSerializers::Sms,
                    SmsMessage.where(order_id: params[:id]).order(date: :desc, message_id: :desc)
      end

      def send_sms
        result = Sms::SendToOrder.call(order_id: params[:id].to_i, text: params[:text])
        return render_failure(result) unless result.success?

        render_json IntegrationSerializers::SmsResult, result.value
      end

      def international_shipment
        result = Delivery::CreateInternationalShipment.call(order_id: params[:id].to_i, **shipment_params)
        return render_failure(result) unless result.success?

        render_json IntegrationSerializers::Shipment, result.value
      end

      private

      def shipment_params
        p = params.permit(:declaredCost, :currency,
                          recipient: %i[firstName lastName phone email countryCode region city street building flat
                                        postCode],
                          terms: %i[incoterm exportReason payerFeesCustoms cargoCategory deliveryType
                                    parcelDescription],
                          items: %i[name nameEng hsCode weightGrams amount cost],
                          parcels: %i[weight width length height])
        r = p[:recipient] || {}
        { recipient: Delivery::CreateInternationalShipment::Recipient.new(
          **%i[first_name last_name phone email country_code region city street building flat post_code]
              .index_with { |key| r[key.to_s.camelize(:lower)] }
        ),
          items: Array(p[:items]).map { |i| shipment_item(i) },
          seats: Array(p[:parcels]).map { |s| shipment_seat(s) },
          declared_cost: p[:declaredCost].nil? ? nil : decimal_value(p[:declaredCost], "declaredCost"),
          currency: p[:currency], terms: (p[:terms] || {}).to_h.transform_keys(&:underscore).symbolize_keys }
      end

      def shipment_item(item)
        Delivery::CreateInternationalShipment::Item.new(
          name: item[:name], name_eng: item[:nameEng], hs_code: item[:hsCode],
          weight_grams: integer_value(item[:weightGrams], "items.weightGrams"),
          amount: item[:amount].nil? ? nil : decimal_value(item[:amount], "items.amount"),
          cost: item[:cost].nil? ? nil : decimal_value(item[:cost], "items.cost")
        )
      end

      def shipment_seat(seat)
        Delivery::CreateInternationalShipment::Seat.new(
          **%i[weight width length height].index_with { |key| decimal_value(seat[key], "parcels.#{key}") }
        )
      end
    end
  end
end
