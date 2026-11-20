require "rails_helper"

RSpec.describe "Auth API" do
  describe "POST /auth/login" do
    let!(:user) { create(:user, role: "Manager", username: "manager1") }

    it "signs in and answers with the user" do
      post "/auth/login", params: { username: "manager1", password: AuthHelpers::TEST_PASSWORD }, as: :json

      expect_contract(200)
      expect(json).to include("userId" => user.id, "username" => "manager1", "role" => "Manager",
                              "mustChangePassword" => false)
      expect(response.cookies["newerp.auth"]).to be_present
      expect(user.login.reload.last_login_at).to be_present
    end

    it "refuses a wrong password with a Problem Details answer" do
      post "/auth/login", params: { username: "manager1", password: "wrong-password" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.media_type).to eq("application/problem+json")
      expect(json).to include("title" => "Невірний логін або пароль", "status" => 401)
    end

    it "refuses a disabled user even with the right password" do
      user.update!(status: false)

      post "/auth/login", params: { username: "manager1", password: AuthHelpers::TEST_PASSWORD }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "closes the login after too many failed tries, even for the right password" do
      LoginThrottle::MAX_FAILURES_PER_USER.times do
        post "/auth/login", params: { username: "manager1", password: "wrong" }, as: :json
      end

      post "/auth/login", params: { username: "manager1", password: AuthHelpers::TEST_PASSWORD }, as: :json

      expect(response).to have_http_status(:too_many_requests)
      expect(response.headers["Retry-After"].to_i).to be_positive
      expect(json["title"]).to eq("Забагато невдалих спроб входу")
    end
  end

  describe "GET /auth/me" do
    it "answers 401 with an empty body without a session" do
      get "/auth/me"

      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to be_empty
    end

    it "answers with the signed-in user" do
      user = sign_in_as("Storekeeper")

      get "/auth/me"

      expect_contract(200)
      expect(json).to include("userId" => user.id, "role" => "Storekeeper")
    end

    it "ends the session when the account's security stamp changes" do
      user = sign_in_as("Manager")
      user.login.update!(security_stamp: UserLogin.new_stamp)

      get "/auth/me"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /auth/change-password" do
    it "changes the password and keeps this session" do
      user = sign_in_as("Manager")

      post "/auth/change-password", params: { currentPassword: AuthHelpers::TEST_PASSWORD,
                                              newPassword: "a-new-password" }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(PasswordHasher.new.verify(user.login.reload.password_hash, "a-new-password")).to be(true)
      get "/auth/me"
      expect(response).to have_http_status(:ok)
    end

    it "refuses a wrong current password" do
      sign_in_as("Manager")

      post "/auth/change-password", params: { currentPassword: "nope", newPassword: "a-new-password" }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json).to include("title" => "Порушено бізнес-правило", "detail" => "Поточний пароль неправильний.")
    end
  end

  describe "POST /auth/logout" do
    it "removes the session" do
      sign_in_as

      post "/auth/logout"
      expect(response).to have_http_status(:no_content)

      get "/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "answers GET /health without a session" do
    get "/health"

    expect(response).to have_http_status(:ok)
    expect(response.body).to eq("Healthy")
  end
end
