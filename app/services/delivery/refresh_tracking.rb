module Delivery
  # Updates the statuses of all open waybills (hourly by RefreshDeliveryTrackingJob, or by hand).
  class RefreshTracking < ApplicationService
    Summary = Data.define(:client_configured, :checked, :updated)

    def initialize(client: NovaPoshta::Client.build)
      @client = client
    end

    def call
      return success(Summary.new(client_configured: false, checked: 0, updated: 0)) unless @client.configured?

      documents = DeliveryDocument.open_for_tracking.includes(:order).to_a
      by_number = documents.group_by(&:number)
      requests = documents.map { |d| NovaPoshta::Client::TrackingRequest.new(number: d.number, phone: d.order&.telephone.to_s) }
      updated = @client.track(requests).sum do |info|
        Array(by_number[info.number]).count { |document| document.apply_tracking(info)&.save! }
      end
      success(Summary.new(client_configured: true, checked: documents.size, updated:))
    end
  end
end
