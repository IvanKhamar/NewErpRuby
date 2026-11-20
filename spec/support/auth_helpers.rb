module AuthHelpers
  TEST_PASSWORD = "test-password-1".freeze
  # A cheap iteration count keeps tests fast; the count is stored in the hash, so verification still works.
  TEST_HASHER = PasswordHasher.new(iterations: 1_000)

  # Signs in through the real login endpoint, so request specs use the same cookie as the browser.
  def sign_in_as(role = "Admin", **attributes)
    user = create(:user, role:, **attributes)
    post "/auth/login", params: { username: user.username, password: TEST_PASSWORD }, as: :json
    raise "login failed: #{response.status}" unless response.ok?

    user
  end

  def json = response.parsed_body
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
