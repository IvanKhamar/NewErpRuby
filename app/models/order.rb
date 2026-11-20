# An order of the shop (OpenCart dd_order, MyISAM: no transactions, so multi-table writes are ordered with care).
class Order < ApplicationRecord
  self.table_name = "dd_order"
  self.primary_key = "order_id"

  has_many :products, class_name: "OrderProduct", inverse_of: :order, dependent: nil
  has_many :options, class_name: "OrderOption", inverse_of: :order, dependent: nil
  has_many :totals, class_name: "OrderTotal", inverse_of: :order, dependent: nil
  has_many :status_logs, class_name: "OrderStatusLog", inverse_of: :order, dependent: nil
  has_one :manager_assignment, class_name: "OrderManager", inverse_of: :order, dependent: nil
  has_one :manager, through: :manager_assignment, source: :user
  belongs_to :status, -> { localized }, class_name: "OrderStatus", foreign_key: :order_status_id,
                                        primary_key: :order_status_id, optional: true, inverse_of: false
  belongs_to :source, -> { localized }, class_name: "OrderSource", foreign_key: :order_source_id,
                                        primary_key: :order_source_id, optional: true, inverse_of: false

  # OpenCart keeps unfinished checkouts with order_status_id = 0; they are not orders yet.
  scope :placed, -> { where("dd_order.order_status_id > 0") }
  scope :with_status, ->(id) { where(order_status_id: id) }
  scope :from_source, ->(id) { where(order_source_id: id) }
  scope :managed_by, ->(user_id) { where(order_id: OrderManager.where(user_id:).select(:order_id)) }
  scope :added_from, ->(day) { where(date_added: day.beginning_of_day..) }
  scope :added_to, ->(day) { where(date_added: ...day.next_day.beginning_of_day) }
  scope :newest_first, -> { order(date_added: :desc, order_id: :desc) }

  # Search like the reference: an order id or phone digits, otherwise phone, names or e-mail containing the text.
  def self.search(text)
    term = text.to_s.strip
    return all if term.empty?

    like = "%#{sanitize_sql_like(term)}%"
    if term.match?(/\A[+-]?\d+\z/) && term.to_i.between?(-(2**31), (2**31) - 1)
      where(order_id: term.to_i).or(where("dd_order.telephone LIKE ?", like))
    else
      where("dd_order.telephone LIKE :q OR dd_order.lastname LIKE :q OR dd_order.firstname LIKE :q " \
            "OR dd_order.email LIKE :q", q: like)
    end
  end

  def customer_name = "#{firstname} #{lastname}"
  def shipping_address = "#{shipping_address_1} #{shipping_address_2}".strip

  # The old site may keep '0000-00-00'; MySQL then gives nil to Rails, which is what the API shows.
  def invoice = invoice_no.to_i.positive? ? "#{invoice_prefix}#{invoice_no}" : nil
end
