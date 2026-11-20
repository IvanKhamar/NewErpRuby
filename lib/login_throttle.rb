# Protection of the login from password guessing (application/auth/throttle.py in the reference).
#
# Counts only failed tries, so a person with the right password never hits the limit. When there are too many,
# the login for that username or address is closed until the window ends, even with the right password
# (otherwise guessing would go on). Counters live in Rails.cache: memory in development and tests, Redis in
# production, so all Puma workers share them.
class LoginThrottle
  MAX_FAILURES_PER_USER = 10 # protects one account attacked from many addresses
  MAX_FAILURES_PER_ADDRESS = 30 # protects against trying many usernames from one address
  WINDOW = 15.minutes

  def initialize(cache: Rails.cache)
    @cache = cache
  end

  # Seconds to wait if the login is closed now; nil means the user may try.
  def retry_after(address, username)
    waits = keys(address, username).filter_map do |key, limit|
      window = @cache.read(key)
      next unless window && window[:count] >= limit

      left = window[:until] - Time.current.to_f
      left if left.positive?
    end
    waits.max
  end

  def failed(address, username)
    keys(address, username).each_key do |key|
      window = @cache.read(key)
      now = Time.current.to_f
      window = { count: 0, until: now + WINDOW.to_i } if window.nil? || window[:until] <= now
      window[:count] += 1
      @cache.write(key, window, expires_in: WINDOW)
    end
  end

  # A successful login resets the username counter; the address counter stays.
  def succeeded(username)
    @cache.delete(user_key(username))
  end

  private

  def keys(address, username)
    { user_key(username) => MAX_FAILURES_PER_USER, "login:ip:#{address || 'unknown'}" => MAX_FAILURES_PER_ADDRESS }
  end

  def user_key(username) = "login:user:#{username.to_s.strip.downcase}"
end
