require "rails_helper"

# The new module: not in the reference contract, so these specs check the JSON directly.
RSpec.describe "Refunds with a recipient check" do
  let(:iban) { "UA213223130000026007233566001" } # a published example IBAN
  let(:order) { create(:order, total: 1500) }

  before do
    sign_in_as("Manager")
    RefundKnownAccount.create!(iban:, holder_name: "Коваленко Олена Петрівна")
  end

  def check(name, iban_text = iban)
    post "/refunds/recipient-checks", params: { iban: iban_text, name:, orderId: order.id }, as: :json
    json
  end

  def refund(check_id, amount, confirm: false)
    post "/refunds", params: { orderId: order.id, recipientCheckId: check_id, amount:, confirmCloseMatch: confirm },
                     as: :json
  end

  it "refunds after a match" do
    result = check("Олена Петрівна Коваленко")
    expect(result).to include("result" => "match", "suggestedName" => nil)

    refund(result["id"], 500)

    expect(response).to have_http_status(:created)
    expect(json).to include("amount" => 500.0, "iban" => "UA21 3223 1300 0002 6007 2335 6600 1")
  end

  it "needs the operator's explicit confirmation after a close match, and shows the holder's name" do
    result = check("Олена Коваленко")
    expect(result).to include("result" => "close_match", "suggestedName" => "Коваленко Олена Петрівна")

    refund(result["id"], 500)
    expect(response).to have_http_status(:bad_request)
    expect(json["detail"]).to start_with("Ім'я лише схоже")

    refund(result["id"], 500, confirm: true)
    expect(response).to have_http_status(:created)
    expect(json["confirmedCloseMatch"]).to be(true)
  end

  it "never refunds after no match, and does not reveal the holder" do
    result = check("Ігор Шевчук")
    expect(result).to include("result" => "no_match", "suggestedName" => nil)

    refund(result["id"], 100, confirm: true)

    expect(response).to have_http_status(:bad_request)
    expect(Refund.count).to eq(0)
  end

  it "tells when the account is unknown" do
    unknown = "UA#{Iban.check_digits('UA', '3052990000026001234567890')}3052990000026001234567890"

    expect(check("Олена Коваленко", unknown)).to include("result" => "account_not_found")
  end

  it "refuses an invalid IBAN and still writes the check to the audit log" do
    post "/refunds/recipient-checks", params: { iban: "UA21322313000002600723356600", name: "Олена" }, as: :json

    expect(response).to have_http_status(:bad_request)
    expect(json["detail"]).to eq("IBAN країни UA має 29 символів, а вказано 28.")
    expect(RefundRecipientCheck.last).to have_attributes(result: "invalid_iban", entered_name: "Олена")
  end

  it "does not refund more than the order total in several refunds" do
    result = check("Олена Петрівна Коваленко")
    refund(result["id"], 1000)

    refund(result["id"], 600)

    expect(response).to have_http_status(:bad_request)
    expect(json["detail"]).to eq("Сума повернення більша за залишок замовлення (500 грн).")
  end

  it "keeps every check in the audit log" do
    check("Олена Коваленко")
    check("Ігор Шевчук")

    get "/refunds/recipient-checks", params: { orderId: order.id }

    expect(json.pluck("result")).to eq(%w[no_match close_match])
  end

  it "is closed to a storekeeper" do
    sign_in_as("Storekeeper")

    post "/refunds/recipient-checks", params: { iban:, name: "x" }, as: :json

    expect(response).to have_http_status(:forbidden)
  end
end
