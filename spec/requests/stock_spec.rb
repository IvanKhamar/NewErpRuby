require "rails_helper"

RSpec.describe "Stock API" do
  it "is closed to a manager" do
    sign_in_as("Manager")

    get "/stock/items"

    expect(response).to have_http_status(:forbidden)
  end

  context "when signed in as a storekeeper" do
    let!(:user) { sign_in_as("Storekeeper") }
    let(:category) { create(:stock_category, name: "Фурнітура") }

    it "lists active items, optionally only those below the minimum" do
      create(:stock_item, name: "Ґудзики", category:, stock: 1, min_stock: 5)
      create(:stock_item, name: "Блискавки", stock: 50, min_stock: 5)
      create(:stock_item, name: "Прихована", status: false)

      get "/stock/items"
      expect_contract(200)
      expect(json.pluck("name")).to eq(%w[Блискавки Ґудзики])

      get "/stock/items", params: { belowMinimumOnly: true }
      expect(json.sole).to include("name" => "Ґудзики", "categoryName" => "Фурнітура", "isBelowMinimum" => true)
    end

    it "creates an item with zero stock" do
      post "/stock/items", params: { name: "Нитки", unit: "шт.", minQuantity: 10, price: "12.50",
                                     categoryId: category.id }, as: :json

      expect_contract(201)
      expect(StockItem.find(json["id"])).to have_attributes(name: "Нитки", stock: 0, price: 12.5)
    end

    it "adjusts the quantity and writes the movement log" do
      item = create(:stock_item, stock: 10)

      post "/stock/items/#{item.id}/adjustments", params: { delta: "-2.5", reason: "Пошив зразка" }, as: :json

      expect_contract(200)
      expect(json).to include("delta" => -2.5, "quantityBefore" => 10.0, "quantityAfter" => 7.5,
                              "reason" => "Пошив зразка", "userId" => user.id)
      expect(item.reload.stock).to eq(7.5)

      get "/stock/items/#{item.id}/movements"
      expect_contract(200)
      expect(json.sole).to include("delta" => -2.5)
    end

    it "never goes below zero" do
      item = create(:stock_item, stock: 1, unit: "м")

      post "/stock/items/#{item.id}/adjustments", params: { delta: -3, reason: "Брак" }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["detail"]).to eq("Недостатньо залишку: є 1 м, списується 3 м.")
      expect(item.reload.stock).to eq(1)
    end

    it "answers 404 for an unknown item" do
      post "/stock/items/999999/adjustments", params: { delta: 1, reason: "x" }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
