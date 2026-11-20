module NovaPost
  # Nova Post International (shipments abroad). The API key buys a JWT, which goes into every call; on a 401 a new
  # JWT is taken once. Creating a shipment is not retried automatically: it would create a second waybill.
  class InternationalClient
    PRODUCTION_URL = "https://api.novapost.com/v.1.0".freeze
    SANDBOX_URL = "https://api-stage.novapost.com/v.1.0".freeze

    Created = Data.define(:ref, :number, :cost)

    class Error < StandardError; end

    def self.build
      key = ENV.fetch("NEWERP_NOVA_POST_API_KEY", "")
      return Stub.new if key.empty?

      new(api_key: key, url: ENV["NEWERP_NOVA_POST_SANDBOX"] == "1" ? SANDBOX_URL : PRODUCTION_URL)
    end

    def initialize(api_key:, url: SANDBOX_URL, connection: nil)
      @api_key = api_key
      @url = url
      @connection = connection || HttpClient.connection(url)
    end

    def configured? = true

    def create(payload)
      created = authorized(:post, "shipments", payload)
      number = created["number"].to_s
      raise Error, "Nova Post International не повернула номер накладної." if number.empty?

      cost = created["cost"] && BigDecimal(created["cost"].to_s)
      Created.new(ref: created["id"].presence&.to_s || number, number:, cost:)
    end

    private

    def authorized(method, path, body)
      response = send_with_token(method, path, body, renew: false)
      response = send_with_token(method, path, body, renew: true) if response.status == 401
      return response.body if response.success?

      raise Error, "Nova Post International відмовила (HTTP #{response.status}): #{error_text(response.body)}"
    rescue Faraday::Error => e
      raise Error, "Nova Post International недоступна: #{e.class.name.demodulize}."
    end

    def send_with_token(method, path, body, renew:)
      @jwt = nil if renew
      @jwt ||= fetch_jwt
      @connection.public_send(method, "#{@url}/#{path}", body, { "Authorization" => @jwt })
    end

    def fetch_jwt
      response = @connection.get("#{@url}/clients/authorization", { apiKey: @api_key })
      raise Error, "Nova Post International не прийняла ключ API (HTTP #{response.status})." unless response.success?

      (response.body.is_a?(Hash) && response.body["jwt"].presence) ||
        raise(Error, "Nova Post International не видала токен: перевірте ключ API.")
    end

    def error_text(body)
      return body.to_s[0, 300] unless body.is_a?(Hash)

      Array(body["errors"]).map { |e| e.is_a?(Hash) ? e["message"] || e.to_json : e.to_s }.join("; ").presence ||
        body["message"].to_s
    end

    # Without a key no waybill can be made: the service answers with a clear message.
    class Stub
      def configured? = false
      def create(_payload) = raise(Error, "Ключ API Nova Post International не задано, тож накладну створити не можна.")
    end
  end
end
