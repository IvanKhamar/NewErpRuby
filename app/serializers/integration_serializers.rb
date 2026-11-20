# JSON of the payment, SMS, receipt and shipment endpoints (phase 3).
module IntegrationSerializers
  class PaymentLink < ApplicationSerializer
    attributes :url
    attribute(:amount) { |l| json_number(l.amount) }
    attributes :currency
    attribute(:is_test, &:test)
  end

  class LiqpayState < ApplicationSerializer
    attributes :state, :label
    attribute(:amount) { |s| json_number(s.amount) }
    attribute(:paid_at) { |s| json_time(s.paid_at) }
    attribute(:is_test, &:test)
  end

  class BankPayment < ApplicationSerializer
    attribute(:id, &:payment_id)
    attribute(:app_code, &:appcode)
    attributes :card
    attribute(:amount) { |p| json_number(p.amount_value) }
    attribute(:balance) { |p| json_number(p.balance_value) }
    attribute(:payer, &:terminal)
    attributes :description
    attribute(:timestamp) { |p| json_time(p.timestamp) }
    attributes :order_id
    attribute(:order_customer) { |p| p.order&.customer_name&.strip }
    attribute(:is_visible) { |p| p.show_status ? true : false }
  end

  class Sms < ApplicationSerializer
    attribute(:id, &:message_id)
    attributes :order_id, :phone, :text, :response
    attribute(:sent_at) { |m| json_time(m.date) }
  end

  class SmsResult < ApplicationSerializer
    attributes :sent
    one :message, resource: Sms
    attribute(:ttn_mismatch) { nil }
  end

  class Cheque < ApplicationSerializer
    attribute(:id, &:cheque_id)
    attributes :order_id
    attribute(:customer) { |c| c.order&.customer_name&.strip }
    attribute(:cashier_id, &:cashbox_user_id)
    attribute(:cashier) { |c| c.cashier&.name }
    attribute(:warehouse) { nil }
    attribute(:requisites) { nil }
    attribute(:sum) { |c| json_number(c.sum) }
    attributes :checkbox_id
    attribute(:is_fiscalized, &:fiscalized?)
    attribute(:receipt_url) { |c| c.fiscalized? ? Checkbox::Client.receipt_url(c.checkbox_id) : nil }
    attribute(:work_shift_id, &:cashbox_work_shift_id)
    attribute(:report_id, &:cashbox_report_id)
    attribute(:date_added) { |c| json_time(c.date_added) }
  end

  class Shipment < ApplicationSerializer
    attributes :id, :order_id, :carrier, :number
    attribute(:cost) { |d| json_number(d.cost) }
    attributes :status, :status_code
    attribute(:tone, &:tone)
    attribute(:is_final, &:final?)
    attributes :recipient_address
    attribute(:redelivery) { |d| d.redelivery ? true : false }
    attribute(:date_created) { |d| json_time(d.date_created) }
    attribute(:date_scheduled) { |d| d.date_scheduled&.iso8601 }
    attribute(:date_payed_keeping) { |d| d.date_payed_keeping&.iso8601 }
  end
end
