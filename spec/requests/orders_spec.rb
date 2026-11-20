require "rails_helper"

RSpec.describe "Orders API" do
  before do
    create(:order_status, order_status_id: 18, name: "Прийнято")
    create(:order_status, order_status_id: 22, name: "Відправлено")
  end

  describe "access" do
    it "is closed to a storekeeper (403, empty body)" do
      sign_in_as("Storekeeper")

      get "/orders"

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to be_empty
    end
  end

  describe "GET /orders" do
    before { sign_in_as("Manager") }

    it "pages the placed orders, newest first, with lookups" do
      older = create(:order, order_status_id: 18, date_added: 2.days.ago)
      newer = create(:order, order_status_id: 22, date_added: 1.day.ago)
      create(:order, order_status_id: 0) # an unfinished checkout is not an order yet

      get "/orders", params: { pageSize: 1 }

      expect_contract(200)
      expect(json).to include("page" => 1, "pageSize" => 1, "totalCount" => 2, "totalPages" => 2)
      expect(json["items"].first).to include("id" => newer.id, "statusName" => "Відправлено")
      expect(older.id).not_to eq(newer.id)
    end

    it "filters by status and finds by phone digits" do
      match = create(:order, order_status_id: 18, telephone: "+380 67 123 45 67")
      create(:order, order_status_id: 22, telephone: "+380 67 123 45 67")
      create(:order, order_status_id: 18, telephone: "+380 50 000 00 00")

      get "/orders", params: { statusId: 18, search: "123 45" }

      expect_contract(200)
      expect(json["items"].pluck("id")).to eq([match.id])
    end

    it "answers 400 for a wrong parameter type" do
      get "/orders", params: { page: "abc" }

      expect(response).to have_http_status(:bad_request)
      expect(json["title"]).to eq("Некоректний запит")
    end
  end

  describe "GET /orders/{id}" do
    before { sign_in_as("Manager") }

    it "shows the card with products and the status history" do
      order = create(:order, order_status_id: 18)
      create(:order_product, order:, name: "Сукня Лана", quantity: 2, price: 600, total: 1200)

      get "/orders/#{order.id}"

      expect_contract(200)
      expect(json).to include("id" => order.id, "statusName" => "Прийнято",
                              "products" => [include("name" => "Сукня Лана")])
    end

    it "answers 404 for an unknown order" do
      get "/orders/999999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /orders/{id}/status" do
    it "changes the status and writes the log" do
      user = sign_in_as("Manager")
      order = create(:order, order_status_id: 18)

      put "/orders/#{order.id}/status", params: { statusId: 22 }, as: :json

      expect_contract(200)
      expect(json).to eq("warnings" => [])
      expect(order.reload.order_status_id).to eq(22)
      expect(OrderStatusLog.last).to have_attributes(order_id: order.id, old_status_id: 18, new_status_id: 22,
                                                     user_id: user.id)
    end

    it "refuses the same status as a broken business rule" do
      sign_in_as("Manager")
      order = create(:order, order_status_id: 18)

      put "/orders/#{order.id}/status", params: { statusId: 18 }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json).to include("title" => "Порушено бізнес-правило", "detail" => "Замовлення вже має цей статус.")
    end
  end

  describe "POST /orders" do
    let(:product) { Product.create!(model: "D-7", price: 900, quantity: 5, status: true, date_added: Time.current) }

    before do
      ProductDescription.create!(product_id: product.id, language_id: ErpSettings.language_id, name: "Сукня Ніжність")
    end

    it "creates a manual order with its lines, totals, manager and first status" do
      user = sign_in_as("Manager")

      post "/orders", as: :json, params: {
        firstname: "Олена", telephone: "+380 00 111 22 33", statusId: 18, shippingMethod: "Нова Пошта",
        paymentMethod: "Передплата", shippingCost: 80, discount: "30",
        lines: [{ productId: product.id, quantity: 2, price: 900 }]
      }

      expect_contract(201)
      order = Order.find(json["orderId"])
      expect(order).to have_attributes(order_status_id: 18, total: 1850, firstname: "Олена")
      expect(order.products.sole).to have_attributes(name: "Сукня Ніжність", quantity: 2)
      expect(order.totals.order(:sort_order).pluck(:code)).to eq(%w[sub_total shipping coupon total])
      expect(order.manager_assignment.user_id).to eq(user.id)
      expect(json["risk"]).to include("level" => CustomerRisk::NEW)
    end

    it "refuses an empty cart" do
      sign_in_as("Manager")

      post "/orders", params: { firstname: "Олена", statusId: 18, shippingMethod: "x", paymentMethod: "y", lines: [] },
                      as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["detail"]).to eq("Кошик не може бути порожнім.")
    end
  end

  describe "rewards" do
    it "adds the order's points once and takes them back" do
      sign_in_as("Manager")
      order = create(:order, customer_id: 7)
      create(:order_product, order:, reward: 25)

      post "/orders/#{order.id}/reward"
      expect_contract(200)
      expect(json).to include("rewardPoints" => 25, "rewardAdded" => true)

      post "/orders/#{order.id}/reward" # a second press adds nothing
      expect(CustomerReward.where(order_id: order.id).count).to eq(1)

      delete "/orders/#{order.id}/reward"
      expect_contract(200)
      expect(json["rewardAdded"]).to be(false)
    end
  end
end
