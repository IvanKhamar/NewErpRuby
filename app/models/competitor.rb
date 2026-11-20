# A competitor whose prices we watch (NewErp's own table erp_competitor). site_url is the site's home page;
# price_regex is an optional pattern whose first group is the price, tried before the usual page markup.
class Competitor < ApplicationRecord
  self.table_name = "erp_competitor"

  has_many :links, class_name: "CompetitorLink", inverse_of: :competitor, dependent: nil

  alias_attribute :is_active, :active

  validate :name_fits, :site_url_is_a_page_address, :price_regex_has_a_group

  before_validation :normalize

  scope :active, -> { where(active: true) }

  # Product pages must be on this host or its subdomains (without "www.").
  def host = PageAddress.host_of(site_url)

  private

  def normalize
    self.name = name.to_s.strip
    self.price_regex = price_regex.to_s.strip
    self.site_url = PageAddress.normalize(site_url) if PageAddress.valid?(site_url)
  end

  def name_fits
    errors.add(:base, "Назва конкурента: від 1 до 100 символів.") unless name.to_s.length.between?(1, 100)
  end

  def site_url_is_a_page_address
    problem = PageAddress.problem(site_url, "Сайт", 255)
    errors.add(:base, problem) if problem
  end

  def price_regex_has_a_group
    problem = Competitors::PriceExtractor.pattern_problem(price_regex)
    errors.add(:base, problem) if problem
  end
end
