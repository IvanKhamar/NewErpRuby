require "rails_helper"

# Every outside service is answered by WebMock; nothing leaves the machine.
RSpec.describe "Integrations: LiqPay, PrivatBank, SMSClub, Checkbox, Nova Post International" do
  before { sign_in_as("Manager") }

  let(:order) { create(:order, total: 1500, telephone: "+38 (067) 123-45-67", email: "buyer@example.com") }

  describe "LiqPay" do
    it "signs a checkout link with the sandbox key when no keys are set" do
      post "/orders/#{order.id}/liqpay-link", params: { amount: 500 }, as: :json

      expect_contract(200)
      expect(json).to include("amount" => 500.0, "currency" => "UAH", "isTest" => true)
      data = Rack::Utils.parse_query(URI(json["url"]).query)["data"]
      expect(JSON.parse(Base64.decode64(data))).to include("action" => "pay", "order_id" => order.id.to_s,
                                                           "amount" => 500.0)
    end

    it "refuses more than the order total" do
      post "/orders/#{order.id}/liqpay-link", params: { amount: 2000 }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["detail"]).to start_with("Сума оплати не може перевищувати")
    end

    it "signs like LiqPay's documentation: base64(sha1(private + data + private))" do
      client = Liqpay::Client.new(public_key: "test-public", private_key: "test-private")
      data, signature = client.sign(action: "status")

      expected = Base64.strict_encode64(OpenSSL::Digest.digest("SHA1", "test-private#{data}test-private"))
      expect(signature).to eq(expected)
    end

    it "reads a paid status from the API" do
      stub_request(:post, "https://www.liqpay.ua/api/request")
        .to_return(headers: { "Content-Type" => "application/json" },
                   body: { status: "success", amount: 1500, end_date: 1_763_600_000_000 }.to_json)
      client = Liqpay::Client.new(public_key: "test-public", private_key: "test-private")

      state = Payments::LiqpayStatus.call(order_id: order.id, client:).value

      expect(state).to have_attributes(state: Payments::LiqpayStatus::PAID, label: "Оплачено", amount: 1500)
    end
  end

  describe "PrivatBank" do
    let(:statement) do
      { StatementsResponse: { statements: [{ "UA000000000000000000000000000" => [
        { "0" => { ID: "tx-1", BPL_DAT_KL: "19.11.2026", BPL_TIM_P: "10:15", BPL_SUM_E: "1500.00", TRANTYPE: "C",
                   BPL_OSND: "Оплата за замовлення 42", BPL_A_NAM: "Тестовий Платник", BPL_C_BAL: "9000.00" } },
        { "1" => { ID: "tx-2", BPL_DAT_KL: "19.11.2026", BPL_TIM_P: "11:00", BPL_SUM_E: "300.00", TRANTYPE: "C",
                   BPL_OSND: "LiqPay payout", BPL_A_NAM: "LiqPay" } }
      ] }] } }
    end

    it "imports incoming payments once, without LiqPay payouts" do
      stub_request(:get, %r{\Ahttps://acp\.privatbank\.ua/api/proxy/transactions})
        .to_return(headers: { "Content-Type" => "application/json" }, body: statement.to_json)
      client = Privatbank::Client.new(account_id: "test-account", token: "test-token")

      first = Payments::ImportBankStatement.call(from: nil, to: nil, client:).value
      second = Payments::ImportBankStatement.call(from: nil, to: nil, client:).value

      expect(first.to_h).to eq(client_configured: true, fetched: 2, added: 1, skipped: 1)
      expect(second.added).to eq(0)

      get "/payments/bank"
      expect_contract(200)
      expect(json["items"].sole).to include("appCode" => "tx-1", "amount" => 1500.0, "payer" => "Тестовий Платник")
    end

    it "reports that no account is configured" do
      post "/payments/bank/import"

      expect_contract(200)
      expect(json).to include("clientConfigured" => false)
    end
  end

  describe "SMSClub" do
    it "logs the SMS even when the service is not configured" do
      post "/orders/#{order.id}/sms", params: { text: "Ваше замовлення відправлено" }, as: :json

      expect_contract(200)
      expect(json).to include("sent" => false)
      expect(json["message"]).to include("phone" => "380671234567", "response" => Smsclub::Client::STUB_RESPONSE)

      get "/orders/#{order.id}/sms"
      expect_contract(200)
      expect(json.size).to eq(1)
    end

    it "sends through the API with a Bearer token" do
      stub = stub_request(:post, "https://im.smsclub.mobi/sms/send")
             .with(headers: { "Authorization" => "Bearer test-token" })
             .to_return(headers: { "Content-Type" => "application/json" },
                        body: { success_request: { info: { "1" => "380671234567" } } }.to_json)

      result = Sms::SendToOrder.call(order_id: order.id, text: "Привіт",
                                     client: Smsclub::Client.new(token: "test-token"))

      expect(result.value.sent).to be(true)
      expect(stub).to have_been_requested
    end
  end

  describe "Checkbox" do
    let(:cashier) { Cashier.create!(name: "Каса 1", description: "", date_added: Time.current) }
    let(:cheque) do
      create(:order_product, order:, price: 1500, total: 1500)
      Cheque.create!(order_id: order.id, cashbox_user_id: cashier.id, sum: 1500, date_added: Time.current)
    end
    let(:client) do
      credentials = Checkbox::Client::Credentials.new(cashier_id: cashier.id, login: "test-login",
                                                      password: "test-password", license_key: "test-license")
      Checkbox::Client.new(cashiers: [credentials])
    end

    it "needs an open shift" do
      result = Cashbox::Fiscalize.call(cheque_id: cheque.id, client:)

      expect(result.error).to eq("У касира «Каса 1» немає відкритої зміни. Спершу відкрийте зміну.")
    end

    it "signs in, sells and marks the receipt fiscalized" do
      WorkShift.create!(cashbox_user_id: cashier.id, date_added: Time.current, date_start: Time.current)
      stub_request(:post, "https://api.checkbox.in.ua/api/v1/cashier/signin")
        .to_return(headers: { "Content-Type" => "application/json" }, body: { access_token: "test-jwt" }.to_json)
      sell = stub_request(:post, "https://api.checkbox.in.ua/api/v1/receipts/sell")
             .with(headers: { "Authorization" => "Bearer test-jwt" }) do |request|
               JSON.parse(request.body)["payments"].sole["value"] == 150_000 # kopecks
             end
             .to_return(headers: { "Content-Type" => "application/json" }, body: { id: "rcpt-1" }.to_json)

      result = Cashbox::Fiscalize.call(cheque_id: cheque.id, client:)

      expect(result).to be_success
      expect(cheque.reload.checkbox_id).to eq("rcpt-1")
      expect(sell).to have_been_requested
    end
  end

  describe "Nova Post International" do
    let(:body) do
      { recipient: { firstName: "Jan", lastName: "Kowalski", phone: "+48 000 000 000", countryCode: "pl",
                     city: "Warszawa", street: "Testowa", building: "1", postCode: "00-001" },
        items: [{ name: "Сукня", nameEng: "Dress", hsCode: "6204.42", weightGrams: 400, cost: 80 }],
        parcels: [{ weight: 0.5, width: 30, length: 20, height: 5 }], declaredCost: 80, currency: "EUR" }
    end

    it "lists every missing customs field in one message" do
      post "/orders/#{order.id}/shipment/international", params: { recipient: { countryCode: "UA" } }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["detail"]).to include("Ім'я", "Країна отримувача (не Україна)", "товари в замовленні")
    end

    it "creates the waybill with a JWT and keeps it as an international document" do
      stub_request(:get, %r{\Ahttps://api-stage\.novapost\.com/v\.1\.0/clients/authorization})
        .to_return(headers: { "Content-Type" => "application/json" }, body: { jwt: "test-jwt" }.to_json)
      create_call = stub_request(:post, "https://api-stage.novapost.com/v.1.0/shipments")
                    .with(headers: { "Authorization" => "test-jwt" }) do |request|
                      sent = JSON.parse(request.body)
                      sent["clientOrder"] == order.id.to_s &&
                        sent["parcels"].sole.values_at("width", "actualWeight") == [300, 400] # cm × 10, items' grams
                    end
                    .to_return(headers: { "Content-Type" => "application/json" },
                               body: { id: "npi-1", number: "NP00000001", cost: 25.5 }.to_json)
      client = NovaPost::InternationalClient.new(api_key: "test-key")
      allow(NovaPost::InternationalClient).to receive(:build).and_return(client)

      post "/orders/#{order.id}/shipment/international", params: body, as: :json

      expect_contract(200)
      expect(json).to include("carrier" => "international", "number" => "NP00000001", "cost" => 25.5, "tone" => 0)
      expect(create_call).to have_been_requested
    end
  end
end
