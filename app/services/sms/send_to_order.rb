module Sms
  # Sends an SMS to the order's phone and logs it, even when the service refused (the answer is in the log).
  # (The reference first checks that a waybill number in the text belongs to this order; not ported.)
  class SendToOrder < ApplicationService
    Sent = Data.define(:sent, :message)

    def initialize(order_id:, text:, client: Smsclub::Client.build)
      @order_id = order_id
      @text = text.to_s.strip
      @client = client
    end

    def call
      order = Order.find_by(order_id: @order_id)
      return not_found("Замовлення #{@order_id} не знайдено.") if order.nil?
      return failure("Текст SMS порожній.") if @text.empty?
      return failure("Текст SMS довший за #{SmsMessage::MAX_LENGTH} символів.") if @text.length > SmsMessage::MAX_LENGTH

      phone = SmsMessage.normalize_phone(order.telephone)
      result = @client.send_sms(phone, @text)
      message = SmsMessage.create!(order_id: order.id, pre_order_id: 0, phone:, text: @text,
                                   response: result.response, date: Time.current)
      success(Sent.new(sent: result.sent, message:))
    end
  end
end
