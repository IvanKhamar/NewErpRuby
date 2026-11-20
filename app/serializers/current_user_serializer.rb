# The signed-in user. mustChangePassword: the password is temporary (given by an admin) and must be changed.
class CurrentUserSerializer < ApplicationSerializer
  attribute(:user_id, &:id)
  attributes :username
  attribute(:full_name, &:full_name)
  attribute(:role, &:role)
  attribute(:must_change_password) { |user| user.must_change_password ? true : false }
end
