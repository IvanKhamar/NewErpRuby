module Privatbank
  # PrivatBank business statements (Autoclient API): the transactions of one account for a period.
  class Client
    BASE_URL = "https://acp.privatbank.ua".freeze

    Transaction = Data.define(:id, :account, :date, :time, :amount, :balance, :incoming, :purpose, :payer,
                              :payer_account, :payer_bank_code, :payer_tax_code)

    class Error < StandardError; end

    def self.build
      account_id = ENV.fetch("NEWERP_PRIVATBANK_ACCOUNT_ID", "")
      token = ENV.fetch("NEWERP_PRIVATBANK_TOKEN", "")
      account_id.empty? || token.empty? ? Stub.new : new(account_id:, token:)
    end

    def initialize(account_id:, token:, connection: nil)
      @account_id = account_id
      @token = token
      @connection = connection || HttpClient.connection(BASE_URL)
    end

    def configured? = true

    def fetch(from, to)
      response = @connection.get("/api/proxy/transactions",
                                 { startDate: from.strftime("%d-%m-%Y"), endDate: to.strftime("%d-%m-%Y") },
                                 { "id" => @account_id, "token" => @token })
      raise Error, "ПриватБанк відмовив (#{response.status})." unless response.success?

      parse(response.body)
    rescue Faraday::Error => e
      raise Error, "ПриватБанк недоступний: #{e.class.name.demodulize}."
    end

    private

    # {"StatementsResponse": {"statements": [{"<account>": [{"0": {...}}, ...]}]}}
    def parse(body)
      root = body.is_a?(String) ? JSON.parse(body) : body
      statements = root.dig("StatementsResponse", "statements")
      raise Error, "ПриватБанк повернув невідому відповідь." unless statements.is_a?(Array)

      statements.flat_map do |statement|
        statement.flat_map do |account, payments|
          Array(payments).filter_map { |wrapper| wrapper.values.first if wrapper.is_a?(Hash) }
                         .map { |p| transaction(account, p) }
        end
      end
    rescue JSON::ParserError
      raise Error, "ПриватБанк повернув невідому відповідь."
    end

    def transaction(account, row)
      Transaction.new(
        id: row["ID"].to_s, account:, date: Date.strptime(row["BPL_DAT_KL"].to_s, "%d.%m.%Y"),
        time: row["BPL_TIM_P"].to_s.presence || "00:00", amount: BigDecimal(row["BPL_SUM_E"].to_s.presence || "0"),
        balance: row["BPL_C_BAL"].presence && BigDecimal(row["BPL_C_BAL"].to_s), incoming: row["TRANTYPE"] != "D",
        purpose: row["BPL_OSND"].to_s, payer: row["BPL_A_NAM"].to_s, payer_account: row["BPL_A_ACC"].to_s,
        payer_bank_code: row["BPL_A_MFO"].to_s, payer_tax_code: row["BPL_A_CRF"].to_s
      )
    end

    class Stub
      def configured? = false
      def fetch(_from, _to) = []
    end
  end
end
