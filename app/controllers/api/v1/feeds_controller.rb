module Api
  module V1
    # Partner XML feeds. Anonymous on purpose: the partner's site downloads its feed by the partner code, as on the
    # old site. The feed carries only what the partner sells anyway (products, prices, pictures), no customer data.
    class FeedsController < BaseController
      allow_unauthenticated_access
      skip_after_action :verify_authorized

      def partner
        partner = Partner.includes(:category_maps, :product_maps).find_by(code: params[:code].to_s, feed_enabled: true)
        return head :not_found if partner.nil?

        render xml: Partners::Feed.new(partner).to_xml, content_type: "application/xml; charset=utf-8"
      end
    end
  end
end
