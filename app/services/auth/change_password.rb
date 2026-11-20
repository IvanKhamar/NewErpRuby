module Auth
  # Changes the own password. Needs the current one; the new security stamp signs out all other sessions.
  class ChangePassword < ApplicationService
    MIN_LENGTH = 8
    MAX_LENGTH = 128

    def initialize(user:, current_password:, new_password:, hasher: PasswordHasher.new)
      @user = user
      @current = current_password.to_s
      @new = new_password.to_s
      @hasher = hasher
    end

    def call
      login = @user.login
      return failure("Обліковий запис не знайдено.") if login.nil?
      return failure("Поточний пароль неправильний.") unless @hasher.verify(login.password_hash, @current)
      return failure("Новий пароль має відрізнятися від поточного.") if @new == @current

      problem = password_problem
      return failure(problem) if problem

      login.update!(password_hash: @hasher.hash(@new), must_change_password: false,
                    security_stamp: UserLogin.new_stamp)
      success(@user)
    end

    private

    def password_problem
      return "Пароль має містити щонайменше #{MIN_LENGTH} символів." if @new.length < MIN_LENGTH
      return "Пароль не довший за #{MAX_LENGTH} символів." if @new.length > MAX_LENGTH

      "Пароль не може збігатися з логіном." if @new.casecmp?(@user.username)
    end
  end
end
