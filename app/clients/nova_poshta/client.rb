module NovaPoshta
  # The domestic Nova Poshta JSON API (one POST endpoint, the model and method in the body). Only tracking is ported.
  #
  # Faraday with timeouts and retries: a network error or a 5xx answer is tried again with a growing pause, so a
  # short outage of the service does not fail the hourly job.
  class Client
    BASE_URL = "https://api.novaposhta.ua/v2.0/json/".freeze
    BATCH_SIZE = 100 # the API takes up to 100 waybills per tracking request

    TrackingRequest = Data.define(:number, :phone)
    TrackingInfo = Data.define(:number, :status, :status_code, :recipient_address, :redelivery, :date_created,
                               :date_scheduled, :date_payed_keeping)

    class Error < StandardError; end

    # Without a key every call is answered by a stub (see .build), so local work never reaches the real service.
    def self.build
      key = ENV.fetch("NEWERP_NOVA_POSHTA_API_KEY", "")
      key.empty? ? Stub.new : new(api_key: key)
    end

    def initialize(api_key:, connection: nil)
      @api_key = api_key
      @connection = connection || Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.request :retry, max: 3, interval: 0.5, backoff_factor: 2, retry_statuses: [429, 500, 502, 503, 504],
                          methods: %i[post] # tracking is a read, safe to repeat although it is a POST
        f.response :json
        f.options.open_timeout = 5
        f.options.timeout = 20
      end
    end

    def configured? = true

    def track(requests)
      requests.each_slice(BATCH_SIZE).flat_map do |batch|
        documents = batch.map { |r| { "DocumentNumber" => r.number, "Phone" => r.phone } }
        call("TrackingDocument", "getStatusDocuments", "Documents" => documents).map { |item| parse_tracking(item) }
      end
    end

    private

    def call(model, method, properties)
      body = @connection.post("", { apiKey: @api_key, modelName: model, calledMethod: method,
                                    methodProperties: properties }).body
      return body["data"] || [] if body.is_a?(Hash) && body["success"] == true

      errors = body.is_a?(Hash) ? Array(body["errors"]) : []
      raise Error, "Нова Пошта відмовила: #{errors.any? ? errors.join('; ') : 'без пояснення'}"
    rescue Faraday::Error => e
      raise Error, "Нова Пошта недоступна: #{e.class.name.demodulize}."
    end

    # Fields come as strings or numbers, dates in several formats.
    def parse_tracking(item)
      code = item["StatusCode"].to_s
      TrackingInfo.new(
        number: item["Number"].to_s, status: item["Status"].to_s,
        status_code: code.match?(/\A-?\d+\z/) ? code.to_i : 0,
        recipient_address: item["RecipientAddress"].to_s, redelivery: %w[1 true].include?(item["Redelivery"].to_s),
        date_created: parse_time(item["DateCreated"]),
        date_scheduled: parse_time(item["ScheduledDeliveryDate"])&.to_date,
        date_payed_keeping: parse_time(item["DatePayedKeeping"])&.to_date
      )
    end

    def parse_time(text)
      return nil if text.blank?

      Time.zone.parse(text.to_s.sub(/\A(\d{2})\.(\d{2})\.(\d{4})/, '\3-\2-\1'))
    rescue ArgumentError
      nil
    end

    # No key: no tracking (the reference does the same), so the job reports "not configured".
    class Stub
      def configured? = false
      def track(_requests) = []
    end
  end
end
