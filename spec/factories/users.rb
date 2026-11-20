FactoryBot.define do
  factory :user do
    transient do
      role { "Admin" }
      password { AuthHelpers::TEST_PASSWORD }
      with_login { true }
    end

    sequence(:username) { |n| "user#{n}" }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    email { Faker::Internet.email(domain: "example.com") }
    status { true }
    user_group_id { 0 }
    date_added { Time.current }

    after(:create) do |user, ctx|
      if ctx.with_login
        UserLogin.create!(user_id: user.id, role: ctx.role, password_hash: AuthHelpers::TEST_HASHER.hash(ctx.password),
                          security_stamp: UserLogin.new_stamp, must_change_password: false)
      end
    end
  end
end
