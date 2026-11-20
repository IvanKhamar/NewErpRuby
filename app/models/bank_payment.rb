# An incoming bank payment (the old site's dd_privatbank). The old site keeps sums as text ("1500.00 UAH"), so
# they stay that way and are read back with .money.
class BankPayment < ApplicationRecord
  self.table_name = "dd_privatbank"
  self.primary_key = "payment_id"

  belongs_to :order, optional: true # 0: not linked to an order yet

  scope :visible, -> { where(show_status: true) }
  scope :newest_first, -> { order(trandate: :desc, trantime: :desc, payment_id: :desc) }

  def self.money_text(value) = "#{format('%.2f', value.round(2, half: :even))} UAH"
  def self.money(text) = BigDecimal(text.to_s.gsub(/[^\d,.-]/, "").tr(",", ".").presence || "0")

  def amount_value = self.class.money(amount)
  def balance_value = self.class.money(rest)

  def timestamp
    Time.zone.local(trandate.year, trandate.month, trandate.day, trantime.hour, trantime.min, trantime.sec)
  end
end
