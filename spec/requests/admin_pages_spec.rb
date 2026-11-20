require "rails_helper"

# The admin pages use the same login, roles and services as the API, with HTML answers.
RSpec.describe "Admin pages" do
  def sign_in_page(role)
    user = create(:user, role:)
    post "/app/session", params: { username: user.username, password: AuthHelpers::TEST_PASSWORD }
    user
  end

  it "sends an anonymous visitor to the login page" do
    get "/app/orders"

    expect(response).to redirect_to("/app/session/new")
  end

  it "logs in and shows the orders list with the menu of the role" do
    create(:order_status, order_status_id: 18, name: "Прийнято")
    create(:order, order_status_id: 18, firstname: "Олена")
    sign_in_page("Manager")

    get "/app/orders"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Олена", "Прийнято")
    expect(response.body).not_to include(">Склад<") # a manager has no stock module
  end

  it "changes an order status through the same service as the API" do
    create(:order_status, order_status_id: 18)
    create(:order_status, order_status_id: 22)
    order = create(:order, order_status_id: 18)
    sign_in_page("Manager")

    patch "/app/orders/#{order.id}/status", params: { status_id: 22 }

    expect(response).to redirect_to("/app/orders/#{order.id}")
    expect(order.reload.order_status_id).to eq(22)
  end

  it "records a stock use and shows a broken rule as a message" do
    item = create(:stock_item, stock: 2, unit: "м")
    sign_in_page("Storekeeper")

    post "/app/stock/#{item.id}/adjustments", params: { delta: "-1,5", reason: "Зразок" }
    expect(item.reload.stock).to eq(0.5)

    post "/app/stock/#{item.id}/adjustments", params: { delta: "-5", reason: "Брак" }
    follow_redirect!
    expect(response.body).to include("Недостатньо залишку")
  end

  it "records a cut from the model page" do
    model = create(:production_model)
    size = create(:production_size, model:)
    sign_in_page("Storekeeper")

    post "/app/production/#{model.id}/operations", params: { operation: "cut", quantities: { size.id.to_s => "3" } }

    expect(size.reload.cut_stock).to eq(3)
  end

  it "shows a forbidden page to a role without the module" do
    sign_in_page("Manager")

    get "/app/stock"

    expect(response).to have_http_status(:forbidden)
  end
end
