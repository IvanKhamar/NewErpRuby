# Per-request globals (reset after every request): who is signed in.
class Current < ActiveSupport::CurrentAttributes
  attribute :user

  def role = user&.role
end
