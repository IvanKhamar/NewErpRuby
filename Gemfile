source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "propshaft"            # asset pipeline for the admin pages
gem "trilogy", "~> 2.7"    # MySQL driver (pure C client, no libmysqlclient needed)
gem "puma", ">= 5.0"
gem "importmap-rails"      # JavaScript without a build step
gem "turbo-rails"          # Hotwire Turbo for the HTML admin pages
gem "stimulus-rails"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]

gem "alba"                 # JSON serializers for the API (see DECISIONS.md: Alba vs Jbuilder)
gem "pundit"               # role policies
gem "sidekiq", "~> 8.1"    # background jobs on Redis
gem "sidekiq-cron"         # schedule from config/schedule.yml
gem "redis"                # Rails cache store on Redis in production (login throttle counters)
gem "faraday"              # HTTP clients of outside services
gem "faraday-retry"        # retries with backoff for those clients
gem "roo"                  # reads Excel (stocktaking sheet import)
gem "caxlsx"               # writes Excel (stocktaking sheet, sales report)
gem "waterdrop"            # Kafka producer for order events

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"              # invented data for factories and db/seeds.rb
  gem "bullet"             # N+1 query detector
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "shoulda-matchers"
  gem "webmock"            # no test ever reaches a real outside service
  gem "committee-rails"    # request specs validate requests and responses against docs/openapi.json
end
