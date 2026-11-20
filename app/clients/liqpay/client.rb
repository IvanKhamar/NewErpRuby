module Liqpay
  # LiqPay card payments: a signed checkout link (no HTTP call) and the payment status (one signed POST).
  # Signature: base64(SHA1(private_key + data + private_key)), data = base64 of the JSON parameters.
  class Client
    BASE_URL = "https://www.liqpay.ua".freeze
    # Without keys the links are signed with these public sandbox placeholders and the status is never "paid",
    # as in the reference. They are not secrets: LiqPay rejects them for real payments.
    SANDBOX_KEY = "sandbox_newerp_test".freeze

    StatusReply = Data.define(:status, :error_code, :amount, :end_date)

    class Error < StandardError; end

    def self.build
      public_key = ENV.fetch("NEWERP_LIQPAY_PUBLIC_KEY", "")
      private_key = ENV.fetch("NEWERP_LIQPAY_PRIVATE_KEY", "")
      if public_key.empty? || private_key.empty?
        return new(public_key: SANDBOX_KEY, private_key: SANDBOX_KEY,
                   test: true)
      end

      new(public_key:, private_key:)
    end

    def initialize(public_key:, private_key:, test: false, connection: nil)
      @public_key = public_key
      @private_key = private_key
      @test = test
      @connection = connection || HttpClient.connection(BASE_URL, timeout: 30)
    end

    def test? = @test

    def checkout_url(order_id:, amount:, currency:, description:)
      data, signature = sign(public_key: @public_key, version: "3", action: "pay", amount: amount.to_f, currency:,
                             description:, order_id: order_id.to_s, language: "uk")
      "#{BASE_URL}/api/3/checkout?#{URI.encode_www_form(data:, signature:)}"
    end

    def status(order_id)
      return StatusReply.new(status: nil, error_code: "payment_not_found", amount: nil, end_date: nil) if @test

      data, signature = sign(action: "status", version: "3", public_key: @public_key, order_id: order_id.to_s)
      response = @connection.post("/api/request") do |request|
        request.headers["Content-Type"] = "application/x-www-form-urlencoded"
        request.body = URI.encode_www_form(data:, signature:)
      end
      raise Error, "LiqPay недоступний: #{response.status}." unless response.success?

      parse_status(response.body)
    rescue Faraday::Error => e
      raise Error, "LiqPay недоступний: #{e.class.name.demodulize}."
    end

    def sign(**parameters)
      data = Base64.strict_encode64(parameters.to_json)
      signature = Base64.strict_encode64(OpenSSL::Digest::SHA1.digest(@private_key + data + @private_key))
      [data, signature]
    end

    private

    def parse_status(body)
      root = body.is_a?(String) ? JSON.parse(body) : body
      end_ms = root["end_date"]
      StatusReply.new(status: root["status"].presence, error_code: root["err_code"].presence,
                      amount: root["amount"] && BigDecimal(root["amount"].to_s),
                      end_date: end_ms && Time.zone.at(end_ms.to_i / 1000))
    rescue JSON::ParserError, ArgumentError
      raise Error, "LiqPay повернув незрозумілу відповідь."
    end
  end
end
