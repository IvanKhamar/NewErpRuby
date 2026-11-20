require "rails_helper"

RSpec.describe "Reports, Excel stocktaking, partner feeds and FAQ" do
  describe "GET /reports/sales" do
    before do
      sign_in_as("Manager")
      create(:order, order_status_id: 18, total: 1000, date_added: Time.zone.local(2026, 11, 3, 10)) # Tuesday
      create(:order, order_status_id: 18, total: 500, date_added: Time.zone.local(2026, 11, 4, 12))
      create(:order, order_status_id: 22, total: 700, date_added: Time.zone.local(2026, 11, 11, 9))
      create(:order, order_status_id: ErpSettings.cancelled_status_id, total: 9999,
                     date_added: Time.zone.local(2026, 11, 5))
    end

    it "groups by weeks from Monday and leaves cancelled orders out" do
      get "/reports/sales", params: { from: "2026-11-01", to: "2026-11-15", group: "Week" }

      expect_contract(200)
      expect(json).to include("orders" => 3, "total" => 2200.0)
      expect(json["rows"].map { |r| [r["start"], r["end"], r["total"]] })
        .to eq([["2026-11-02", "2026-11-08", 1500.0], ["2026-11-09", "2026-11-15", 700.0]])
    end

    it "refuses an upside-down period" do
      get "/reports/sales", params: { from: "2026-11-15", to: "2026-11-01" }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "stocktaking with Excel" do
    let!(:user) { sign_in_as("Storekeeper") }
    let!(:linen) { create(:stock_item, name: "Льон", stock: 10, price: 200) }
    let!(:thread) { create(:stock_item, name: "Нитки", stock: 50, price: 2) }

    def counted_sheet(rows)
      package = Axlsx::Package.new
      package.workbook.add_worksheet { |s| ([Stock::Stocktaking::COLUMNS] + rows).each { |r| s.add_row(r) } }
      package.to_stream.read
    end

    it "exports a sheet to count on" do
      get "/stock/stocktaking/sheet.xlsx"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Api::V1::StockController::XLSX)
      Tempfile.create(%w[sheet .xlsx], binmode: true) do |file|
        file.write(response.body)
        file.flush
        sheet = Roo::Excelx.new(file.path).sheet(0)
        expect(sheet.row(1)).to eq(Stock::Stocktaking::COLUMNS)
        expect(sheet.column(2)).to include("Льон", "Нитки")
      end
    end

    it "previews a counted sheet with errors per row, writing nothing" do
      body = counted_sheet([[linen.id, "Льон", "", "м", 10, "8,5"], [thread.id, "Нитки", "", "шт.", 50, ""],
                            ["abc", "?", "", "", 0, "3"]])

      post "/stock/stocktaking/preview", params: body, headers: { "CONTENT_TYPE" => "application/octet-stream" }

      expect_contract(200)
      expect(json["lines"].sole).to include("itemId" => linen.id, "booked" => 10.0, "actual" => 8.5,
                                            "difference" => -1.5)
      expect(json["errors"]).to eq(["Рядок 4: немає ID позиції або він не число."])
      expect(linen.reload.stock).to eq(10)
    end

    it "applies the counts in one go and logs them as stocktaking" do
      post "/stock/stocktaking", params: { counts: [{ itemId: linen.id, actual: 8 }, { itemId: thread.id, actual: 50 }],
                                           comment: "листопад" }, as: :json

      expect_contract(200)
      expect(json).to eq("counted" => 2, "changed" => 1, "value" => -400.0)
      expect(StockLog.where(item_id: linen.id).sole).to have_attributes(comment: "Інвентаризація: листопад",
                                                                        user_id: user.id)
    end
  end

  describe "GET /feeds/{code}.xml" do
    let!(:partner) do
      Partner.create!(code: "eva", name: "EVA", status: true, feed_enabled: true, vendor_name: "Vidro",
                      default_quantity: 5, date_added: Time.current, date_modified: Time.current)
    end

    before do
      product = Product.create!(model: "D-9", sku: "1234", price: 1000, quantity: 1, status: true,
                                image: "catalog/d9.jpg",
                                date_added: Time.current)
      ProductDescription.create!(product_id: product.id, language_id: ErpSettings.language_id, name: "Сукня Ліра",
                                 description: "&lt;p&gt;Льон&lt;/p&gt;&lt;script&gt;x()&lt;/script&gt;")
      ProductToCategory.create!(product_id: product.id, category_id: 59)
      CategoryDescription.create!(category_id: 59, language_id: ErpSettings.language_id, name: "Сукні")
      PartnerCategoryMap.create!(partner_id: partner.id, category_id: 59, external_id: "777", percent_supply: 10)
    end

    it "is served without a login, with the partner's markup and plain-text descriptions" do
      get "/feeds/eva.xml"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/xml")
      doc = Nokogiri::XML(response.body)
      offer = doc.at_xpath("//offers/offer")
      expect(doc.at_xpath("//categories/category")["eva_id"]).to eq("777")
      expect(offer.at_xpath("price").text).to eq("1100") # 1000 + 10 %
      expect(offer.at_xpath("description_ua").text).to eq("Льон\nx()")
      expect(offer.at_xpath("param[@name='Штрихкод']").text).to match(/\A482\d{10}\z/)
    end

    it "answers 404 for an unknown partner or a feed that is off" do
      partner.update!(feed_enabled: false)

      get "/feeds/eva.xml"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "FAQ" do
    before { sign_in_as("Manager") }

    it "keeps only safe HTML in the answer" do
      post "/catalog/faq", as: :json, params: {
        question: "Як обрати розмір?",
        answer: '<p>Дивіться <a href="javascript:x()">таблицю</a></p><script>x()</script>'
      }

      expect_contract(201)
      expect(json["answer"]).to eq("<p>Дивіться <a rel=\"noopener noreferrer\">таблицю</a></p>")

      put "/catalog/faq/#{json['id']}", params: { question: "Як обрати розмір?", answer: "<b>M</b>" }, as: :json
      expect_contract(200)

      get "/catalog/faq"
      expect_contract(200)
      expect(json.sole["answer"]).to eq("<b>M</b>")
    end
  end
end
