require "rails_helper"

RSpec.describe "Pre-orders, competitor prices and delivery tracking" do
  before { sign_in_as("Manager") }

  def size(quantity:, quota:, subtract: true)
    product = Product.create!(model: "D-1", price: 1000, quantity: 0, status: true, date_added: Time.current)
    ProductDescription.create!(product_id: product.id, language_id: ErpSettings.language_id, name: "Сукня")
    ProductOptionValue.create!(product_id: product.id, product_option_id: 1, option_id: 11, option_value_id: 2,
                               quantity:, pre_order_quantity: quota, subtract:, price: 0, price_prefix: "+",
                               points: 0, points_prefix: "+", weight: 0, weight_prefix: "+")
  end

  describe "pre-orders" do
    it "lists sizes with their availability and settles what was sold ahead" do
      sold_ahead = size(quantity: -3, quota: 5)
      size(quantity: 4, quota: 0)

      get "/preorders"
      expect_contract(200)
      expect(json.find { |r| r["productOptionValueId"] == sold_ahead.id }).to include("availability" => 1, "quota" => 5)

      post "/preorders/settle"
      expect_contract(200)
      expect(json).to eq("sizes" => 1)
      expect(sold_ahead.reload).to have_attributes(quantity: 0, pre_order_quantity: 2)
    end

    it "never lets the limit go below zero" do
      expect(ProductOptionValue.settled(-7, 5)).to eq([-2, 0])
      expect(ProductOptionValue.settled(3, 5)).to eq([3, 5])
    end

    it "sets a limit and the expected date" do
      value = size(quantity: 0, quota: 0)

      put "/preorders/#{value.id}", params: { quota: 10, dateAvailable: "2026-12-15" }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(value.reload).to have_attributes(pre_order_quantity: 10, date_available: Date.new(2026, 12, 15))
    end
  end

  describe "competitors" do
    let(:product) { Product.create!(model: "D-2", price: 1500, quantity: 0, status: true, date_added: Time.current) }

    before do
      allow(Resolv).to receive(:getaddresses).and_return(["93.184.216.34"])
    end

    it "adds a competitor and a product page, then checks the price" do
      post "/competitors", params: { name: "Інший магазин", siteUrl: "https://www.Shop.example" }, as: :json
      expect_contract(201)
      competitor_id = json["id"]
      expect(json["siteUrl"]).to eq("https://www.shop.example/")

      post "/competitors/links", params: { competitorId: competitor_id, productId: product.id,
                                           url: "https://shop.example/dress-2" }, as: :json
      expect_contract(201)

      stub_request(:get, "https://shop.example/dress-2")
        .to_return(body: '<meta property="product:price:amount" content="1 399,00">')
      post "/competitors/check"
      expect_contract(200)
      expect(json).to eq("checked" => 1, "changed" => 1, "failed" => 0)
      expect(CompetitorPrice.sole.price).to eq(1399)

      get "/competitors/links"
      expect_contract(200)
      expect(json.sole).to include("lastPrice" => 1399.0, "lastError" => "")
    end

    it "refuses a product page on another site" do
      competitor = Competitor.create!(name: "Магазин", site_url: "https://shop.example", created_at: Time.current)

      post "/competitors/links", params: { competitorId: competitor.id, productId: product.id,
                                           url: "https://elsewhere.example/x" }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["detail"]).to eq("Сторінка має бути на сайті «Магазин» (shop.example).")
    end
  end

  describe "delivery tracking" do
    it "reports that the client is not configured without a key" do
      post "/delivery/tracking/refresh"

      expect_contract(200)
      expect(json).to eq("clientConfigured" => false, "checked" => 0, "updated" => 0)
    end

    it "updates open waybills from Nova Poshta" do
      order = create(:order, telephone: "+380000000001")
      document = DeliveryDocument.create!(order_id: order.id, number: "20450000000001", status_code: 1,
                                          carrier: DeliveryDocument::NOVA_POSHTA)
      stub_request(:post, NovaPoshta::Client::BASE_URL).to_return(
        headers: { "Content-Type" => "application/json" },
        body: { success: true, data: [{ Number: "20450000000001", StatusCode: "7", Status: "Прибув у відділення",
                                        DatePayedKeeping: "2026-11-25 00:00:00" }] }.to_json
      )

      summary = Delivery::RefreshTracking.call(client: NovaPoshta::Client.new(api_key: "test-key")).value

      expect(summary.to_h).to eq(client_configured: true, checked: 1, updated: 1)
      expect(document.reload).to have_attributes(status_code: 7, date_payed_keeping: Date.new(2026, 11, 25))
    end
  end

  describe "the jobs" do
    it "are scheduled in config/schedule.yml and only call services" do
      schedule = YAML.load_file(Rails.root.join("config/schedule.yml"))

      expect(schedule.values.pluck("class")).to contain_exactly("SettlePreOrdersJob", "CheckCompetitorPricesJob",
                                                                "RefreshDeliveryTrackingJob")
      schedule.each_value { |job| expect(Fugit.parse_cron(job["cron"])).to be_present }
    end

    it "settles pre-orders when the hourly job runs" do
      value = size(quantity: -1, quota: 1)

      SettlePreOrdersJob.perform_now

      expect(value.reload.pre_order_quantity).to eq(0)
    end
  end
end
