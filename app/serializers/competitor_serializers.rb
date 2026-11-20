# JSON of the competitor prices API (CompetitorDto, CompetitorLinkDto, CompetitorCheckResult).
module CompetitorSerializers
  class Competitor < ApplicationSerializer
    attributes :id, :name, :site_url
    attribute(:price_regex) { |c| c.price_regex.to_s }
    attribute(:is_active, &:active)
    attribute(:links) { |c| c.respond_to?(:links_count) ? c.links_count.to_i : c.links.size }
  end

  class Link < ApplicationSerializer
    attributes :id, :competitor_id
    attribute(:competitor_name) { |l| l.competitor.name }
    attributes :product_id
    attribute(:product_name) { |l| l.product&.name.to_s }
    attributes :url
    attribute(:last_price) { |l| number(l.last_price) }
    attribute(:last_checked_at) { |l| local_time(l.last_checked_at) }
    attribute(:last_error) { |l| l.last_error.to_s }
  end

  class CheckResult < ApplicationSerializer
    attributes :checked, :changed, :failed
  end
end
