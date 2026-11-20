module Api
  module V1
    # Competitor prices: competitors, pages of our products on their sites, the price check (Admin, Manager).
    class CompetitorsController < BaseController
      before_action -> { authorize :orders, :manage? }

      def index
        competitors = Competitor.left_joins(:links).group(:id).order(:name)
                                .select("erp_competitor.*, COUNT(erp_competitor_link.id) AS links_count")
        render_json CompetitorSerializers::Competitor, competitors
      end

      def create
        p = params.permit(:name, :siteUrl, :priceRegex, :isActive)
        competitor = Competitor.new(name: p[:name], site_url: p[:siteUrl], price_regex: p[:priceRegex],
                                    active: p.fetch(:isActive, true), created_at: Time.current)
        raise DomainError, competitor.errors.full_messages.first unless competitor.save

        render_json CompetitorSerializers::Competitor, competitor, status: :created
      end

      def links
        links = CompetitorLink.includes(:competitor, product: :description).order(:product_id, :id)
        links = links.where(product_id: int_param(:productId)) if params[:productId].present?
        render_json CompetitorSerializers::Link, links
      end

      def add_link
        p = params.permit(:competitorId, :productId, :url)
        competitor_id = integer_value(p[:competitorId], "competitorId")
        product_id = integer_value(p[:productId], "productId")
        competitor = Competitor.find_by(id: competitor_id)
        if competitor.nil?
          return render_problem(404, ProblemDetails::NOT_FOUND,
                                "Конкурента #{competitor_id} не знайдено.")
        end
        # A typed id, never the raw string: exists?("…") would treat a string as an SQL condition.
        raise DomainError, "Товару #{product_id} не знайдено." unless Product.exists?(product_id:)

        link = competitor.links.new(product_id:, url: p[:url].to_s.strip, created_at: Time.current)
        raise DomainError, link.errors.full_messages.first unless link.valid?

        link.url = PageAddress.normalize(link.url)
        link.save!
        render_json CompetitorSerializers::Link, link, status: :created
      end

      # Reads all prices now, like the daily job. Pages are slow, so this request can take a while.
      def check
        render_json CompetitorSerializers::CheckResult, Competitors::CheckPrices.call.value
      end
    end
  end
end
