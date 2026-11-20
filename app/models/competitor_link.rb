# A page of our product on a competitor's site with the last price found (erp_competitor_link).
# last_error says why the last check failed; empty: it worked.
class CompetitorLink < ApplicationRecord
  AUTO = "auto".freeze     # the price was read from the page
  MANUAL = "manual".freeze # the price was typed in

  self.table_name = "erp_competitor_link"

  belongs_to :competitor, inverse_of: :links
  belongs_to :product, optional: true # dd_product is MyISAM: no foreign key
  has_many :prices, class_name: "CompetitorPrice", foreign_key: :link_id, inverse_of: :link, dependent: nil

  validate :url_is_on_the_site

  # A price found or typed in. The history gets a row only when the price changed (or is found the first time).
  def record_price(price, source, now = Time.current)
    raise DomainError, "Ціна має бути більшою за нуль, не більше двох знаків після коми." unless price.positive?

    prices.build(price:, source:, checked_at: now) if last_price != price
    assign_attributes(last_price: price, last_checked_at: now, last_error: "")
  end

  # The check failed: the last price stays, the reason goes into last_error.
  def record_failure(error, now = Time.current)
    assign_attributes(last_checked_at: now, last_error: error.to_s[0, 255])
  end

  private

  def url_is_on_the_site
    problem = PageAddress.problem(url, "Сторінка товару", 500)
    return errors.add(:base, problem) if problem
    return if competitor.nil? || PageAddress.on_site?(url, competitor.host)

    errors.add(:base, "Сторінка має бути на сайті «#{competitor.name}» (#{competitor.host}).")
  end
end
