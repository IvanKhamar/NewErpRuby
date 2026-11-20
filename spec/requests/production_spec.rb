require "rails_helper"

RSpec.describe "Production API" do
  before { sign_in_as("Storekeeper") }

  let(:model) { create(:production_model, name: "Сукня Лана") }
  let!(:size_m) { create(:production_size, model:, size_name: "M") }
  let!(:front) { create(:production_component, model:, name: "Перед") }
  let!(:fabric) { create(:stock_item, name: "Льон", unit: "м", stock: 10) }
  let!(:thread) { create(:stock_item, name: "Нитки", unit: "шт.", stock: 100) }

  def put_bom
    put "/production/components/#{front.id}/bom", params: { rows: [{ itemId: fabric.id, qtyPerUnit: "1.5" }] },
                                                  as: :json
    put "/production/models/#{model.id}/sewn-bom", as: :json, params: {
      rows: [{ componentId: front.id, qtyPerUnit: 1 }, { itemId: thread.id, qtyPerUnit: 2 }]
    }
  end

  it "keeps the BOMs and shows them on the model card" do
    put_bom
    expect(response).to have_http_status(:no_content)

    get "/production/models/#{model.id}"

    expect_contract(200)
    expect(json["components"].sole["bom"].sole).to include("itemName" => "Льон", "qtyPerUnit" => 1.5)
    expect(json["sewnBom"].size).to eq(2)
  end

  it "cuts: parts are added and the fabric is written off by the cutting BOM" do
    put_bom

    post "/production/models/#{model.id}/cut", params: { quantities: [{ sizeId: size_m.id, quantity: 4 }] }, as: :json

    expect_contract(200)
    expect(json).to eq("sizes" => [{ "sizeId" => size_m.id, "sizeName" => "M", "before" => 0.0, "after" => 4.0 }],
                       "warnings" => [])
    expect(fabric.reload.stock).to eq(4) # 10 − 4 × 1.5
    expect(ComponentStock.find([front.id, size_m.id]).stock).to eq(4)
    expect(StockLog.where(item_id: fabric.id).sole.comment).to start_with("Крій: Сукня Лана, Перед, M x4")
  end

  it "sews: cut parts and threads are taken, a shortage becomes a warning, not an error" do
    put_bom
    post "/production/models/#{model.id}/cut", params: { quantities: [{ sizeId: size_m.id, quantity: 2 }] }, as: :json

    post "/production/models/#{model.id}/sewn", params: { quantities: [{ sizeId: size_m.id, quantity: 3 }] }, as: :json

    expect_contract(200)
    expect(json["warnings"].sole).to start_with("Бракує розкроєних деталей «Перед» розміру M: 1 шт.")
    expect(size_m.reload.sewn_stock).to eq(3)
    expect(thread.reload.stock).to eq(94)
  end

  it "refuses to ship more than was sewn" do
    post "/production/models/#{model.id}/ship", params: { quantities: [{ sizeId: size_m.id, quantity: 1 }] }, as: :json

    expect(response).to have_http_status(:bad_request)
    expect(json["detail"]).to eq("Розмір M: пошито лише 0, а вказано 1.")
  end

  it "lists models with their totals and deficit" do
    size_m.update!(sewn_stock: 4)

    get "/production/models"

    expect_contract(200)
    expect(json.sole).to include("name" => "Сукня Лана", "totalSewn" => 4.0, "deficit" => 6.0)
  end

  it "answers 404 for an unknown model" do
    post "/production/models/999999/cut", params: { quantities: [{ sizeId: 1, quantity: 1 }] }, as: :json

    expect(response).to have_http_status(:not_found)
    expect(json["detail"]).to eq("Модель 999999 не знайдено.")
  end
end
