# An SMS sent (or tried) to a customer, with the service's answer (the old site's dd_sms_log).
class SmsMessage < ApplicationRecord
  MAX_LENGTH = 670 # SMSClub: up to 10 Cyrillic parts of 67 characters

  self.table_name = "dd_sms_log"
  self.primary_key = "message_id"

  belongs_to :order, optional: true

  # A Ukrainian mobile as 380XXXXXXXXX: "0671234567" and "+38 (067) 123-45-67" become 380671234567.
  def self.normalize_phone(phone)
    digits = phone.to_s.gsub(/\D/, "")
    digits = "38#{digits}" if digits.length == 10 && digits.start_with?("0")
    return digits if digits.length == 12 && digits.start_with?("380")

    raise DomainError, "Номер \"#{phone}\" не схожий на український мобільний."
  end
end
