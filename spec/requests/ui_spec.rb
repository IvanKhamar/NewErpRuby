require "rails_helper"

RSpec.describe "The React app at /ui" do
  it "answers a client-side route with the app's index.html, without a login" do
    Dir.mktmpdir do |dir|
      index = Pathname(dir).join("index.html")
      index.write('<div id="root"></div>')
      stub_const("UiController::INDEX", index)

      get "/ui/orders/42"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('id="root"')
    end
  end

  it "explains how to build it when it is not built" do
    stub_const("UiController::INDEX", Pathname("/nonexistent/index.html"))

    get "/ui/orders"

    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("npm run build")
  end
end
