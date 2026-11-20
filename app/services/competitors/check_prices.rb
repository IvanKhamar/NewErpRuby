module Competitors
  # Reads the prices of every page of active competitors (daily by CheckCompetitorPricesJob, or by hand).
  # One failed page does not stop the rest, and every page is saved at once: sites answer slowly, and what is done
  # must not be lost because of the next one.
  class CheckPrices < ApplicationService
    Summary = Data.define(:checked, :changed, :failed)

    def initialize(fetcher: PageFetcher.new)
      @fetcher = fetcher
    end

    def call
      links = CompetitorLink.joins(:competitor).merge(Competitor.active).includes(:competitor).order(:id).to_a
      outcomes = links.map { |link| check(link) }
      success(Summary.new(checked: links.size, changed: outcomes.count(:changed), failed: outcomes.count(:failed)))
    end

    private

    def check(link)
      before = link.last_price
      html = @fetcher.fetch(link.url, link.competitor.host)
      found = PriceExtractor.extract(html, link.competitor.price_regex)
      if found
        price = found.round(2, half: :up)
        link.record_price(price, CompetitorLink::AUTO)
        before == price ? :same : :changed
      else
        link.record_failure("Ціну на сторінці не знайдено.")
        :failed
      end
    rescue PageFetcher::Error => e
      link.record_failure(e.message)
      :failed
    ensure
      # The address was checked when the link was added; only the price and the check result change here.
      link.save!(validate: false)
    end
  end
end
