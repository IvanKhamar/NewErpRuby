module Checkbox
  # Checkbox, the software cash register (PRRO): fiscal sale receipts. Each cashier signs in with their own login and
  # password; the token is kept and taken again once if Checkbox answers 401 (expired).
  # Sales are never retried automatically: a repeated POST could register the sale twice with the tax office.
  class Client
    BASE_URL = "https://api.checkbox.in.ua".freeze

    Credentials = Data.define(:cashier_id, :login, :password, :license_key)

    class Error < StandardError; end

    # NEWERP_CHECKBOX_CASHIERS: a JSON list [{"cashierId":1,"login":"…","password":"…","licenseKey":"…"}].
    def self.build
      list = JSON.parse(ENV.fetch("NEWERP_CHECKBOX_CASHIERS", "[]"))
      cashiers = list.map do |c|
        Credentials.new(cashier_id: c["cashierId"].to_i, login: c["login"].to_s, password: c["password"].to_s,
                        license_key: c["licenseKey"].to_s)
      end
      new(cashiers:)
    end

    def initialize(cashiers:, connection: nil)
      @cashiers = cashiers.index_by(&:cashier_id)
      @tokens = {}
      @connection = connection || Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json, content_type: /\bjson$/
        f.headers["X-Client-Name"] = "NewErpRuby"
        f.headers["X-Client-Version"] = "1.0"
        f.options.open_timeout = 5
        f.options.timeout = 30
      end
    end

    def usable?(cashier_id) = @cashiers.key?(cashier_id)

    def self.receipt_url(receipt_id) = "#{BASE_URL}/api/v1/receipts/#{ERB::Util.url_encode(receipt_id)}/html"

    # receipt: a FiscalReceipt; returns Checkbox's receipt id.
    def sell(cashier_id, receipt)
      body = authorized(cashier_id, :post, "/api/v1/receipts/sell", receipt.to_checkbox)
      body.is_a?(Hash) && body["id"].present? ? body["id"].to_s : raise(Error, "Checkbox не повернув id чека.")
    end

    private

    def authorized(cashier_id, method, path, body)
      cashier = @cashiers[cashier_id] || raise(Error, "Для касира #{cashier_id} не задано ключі Checkbox.")
      2.times do |attempt|
        token = @tokens[cashier_id] ||= sign_in(cashier)
        response = @connection.public_send(method, path, body, { "Authorization" => "Bearer #{token}" })
        if response.status == 401 && attempt.zero?
          @tokens.delete(cashier_id) # the token expired: sign in again once
          next
        end
        return ensure_success(response).body
      end
    rescue Faraday::Error => e
      raise Error, "Checkbox недоступний: #{e.class.name.demodulize}."
    end

    def sign_in(cashier)
      response = ensure_success(@connection.post("/api/v1/cashier/signin", { login: cashier.login,
                                                                             password: cashier.password }))
      (response.body.is_a?(Hash) && response.body["access_token"].presence) ||
        raise(Error, "Checkbox не повернув токен касира.")
    end

    def ensure_success(response)
      return response if response.success?

      message = response.body.is_a?(Hash) ? response.body["message"] : response.body
      raise Error, "Checkbox відмовив (#{response.status}): #{message}"
    end
  end
end
