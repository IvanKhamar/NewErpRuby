# A Nova Poshta waybill of an order (the old site's dd_novaposhta_document).
class DeliveryDocument < ApplicationRecord
  NOVA_POSHTA = "novaposhta".freeze
  INTERNATIONAL = "international".freeze # Nova Post International; the domestic API does not track them
  # Nova Poshta status codes after which the waybill does not change any more (received, refused, returned...).
  FINAL_STATUS_CODES = [9, 11, 102, 103, 104, 105, 107, 108].freeze

  self.table_name = "dd_novaposhta_document"

  belongs_to :order

  # Waybills whose status can still change, which the domestic API knows.
  scope :open_for_tracking, lambda {
    where.not(number: "").where.not(status_code: FINAL_STATUS_CODES).where.not(carrier: INTERNATIONAL)
  }

  def final? = FINAL_STATUS_CODES.include?(status_code)

  # How the status is coloured in the list, as the old site did; a number in JSON: 0 info, 1 success, 2 warning,
  # 3 error. Received counts as success, but with cash on delivery only when the money came back (code 11).
  def tone
    return 1 if (status_code == 9 && !redelivery) || (status_code == 11 && redelivery) || status_code == 106
    return 3 if [3, 107].include?(status_code)
    return 2 if [102, 103, 105, 108].include?(status_code)

    0
  end

  # Like the old site, the record changes only when the status code changed. Returns self if it changed, else nil.
  def apply_tracking(info)
    return nil if info.status_code == status_code

    assign_attributes(status: info.status.to_s[0, 255], status_code: info.status_code,
                      recipient_address: info.recipient_address.to_s[0, 255], redelivery: info.redelivery,
                      date_created: info.date_created || date_created, date_scheduled: info.date_scheduled,
                      date_payed_keeping: info.date_payed_keeping)
    self
  end
end
