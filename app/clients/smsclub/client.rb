module Smsclub
  # SMSClub JSON API with a Bearer token. Sending is not retried: a repeated POST could send the SMS twice.
  class Client
    BASE_URL = "https://im.smsclub.mobi".freeze
    SENDER = "Vidro.ua".freeze
    STUB_RESPONSE = "НЕ НАДІСЛАНО: SMSClub не налаштовано (немає токена).".freeze

    SendResult = Data.define(:sent, :response)

    def self.build
      token = ENV.fetch("NEWERP_SMSCLUB_TOKEN", "")
      token.empty? ? Stub.new : new(token:)
    end

    def initialize(token:, connection: nil)
      @token = token
      @connection = connection || HttpClient.connection(BASE_URL, timeout: 30)
    end

    def send_sms(phone, text)
      response = @connection.post("/sms/send", { phone: [phone], message: text, src_addr: SENDER },
                                  { "Authorization" => "Bearer #{@token}" })
      body = response.body
      SendResult.new(sent: response.success? && accepted?(body, phone),
                     response: body.present? ? body.to_json : "HTTP #{response.status}")
    rescue Faraday::Error => e
      SendResult.new(sent: false, response: "НЕ НАДІСЛАНО: SMSClub недоступний (#{e.class.name.demodulize})")
    end

    private

    # SMSClub lists the accepted numbers in success_request.info as {"<sms id>": "<phone>"}.
    def accepted?(body, phone)
      info = body.is_a?(Hash) ? body.dig("success_request", "info") : nil
      info.is_a?(Hash) && info.value?(phone)
    end

    # Sends nothing; the attempt still gets into the order's SMS log.
    class Stub
      def send_sms(_phone, _text) = SendResult.new(sent: false, response: STUB_RESPONSE)
    end
  end
end
