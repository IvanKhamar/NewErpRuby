source "https://rubygems.org"

ruby file: ".ruby-version"

gem "bootsnap", require: false
gem "importmap-rails"      # JavaScript without a build step
gem "propshaft"            # asset pipeline for the admin pages
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "stimulus-rails"
gem "trilogy", "~> 2.7"    # MySQL driver (pure C client, no libmysqlclient needed)
gem "turbo-rails"          # Hotwire Turbo for the HTML admin pages
gem "tzinfo-data", platforms: %i[windows jruby]

gem "alba"                 # JSON serializers for the API (see DECISIONS.md: Alba vs Jbuilder)
gem "caxlsx"               # writes Excel (stocktaking sheet, sales report)
gem "faraday"              # HTTP clients of outside services
gem "faraday-retry"        # retries with backoff for those clients
gem "pundit"               # role policies
gem "redis"                # Rails cache store on Redis in production (login throttle counters)
gem "roo"                  # reads Excel (stocktaking sheet import)
gem "sidekiq", "~> 8.1"    # background jobs on Redis
gem "sidekiq-cron"         # schedule from config/schedule.yml
gem "waterdrop"            # Kafka producer for order events

group :development, :test do
  gem "brakeman", require: false
  gem "bullet"             # N+1 query detector
  gem "bundler-audit", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails"
  gem "faker"              # invented data for factories and db/seeds.rb
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "committee-rails"    # request specs validate requests and responses against docs/openapi.json
  gem "shoulda-matchers"
  gem "webmock"            # no test ever reaches a real outside service
end
