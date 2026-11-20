module Auth
  # Checks a username and password. The answer never tells why a login failed, so it does not reveal which
  # usernames exist; an unknown username is hashed anyway, so it takes as long as a known one.
  class Login < ApplicationService
    def initialize(username:, password:, hasher: PasswordHasher.new)
      @username = username.to_s.strip
      @password = password.to_s
      @hasher = hasher
    end

    def call
      return failure("Невірний логін або пароль") if @username.empty? || @password.empty?

      user = User.includes(:login).find_by(username: @username)
      if user&.login.nil?
        @hasher.hash(@password)
        return failure("Невірний логін або пароль")
      end

      # The password is checked for a disabled user too, for the same timing reason.
      valid = @hasher.verify(user.login.password_hash, @password) && user.status
      return failure("Невірний логін або пароль") unless valid

      user.login.update!(last_login_at: Time.current)
      success(user)
    end
  end
end
