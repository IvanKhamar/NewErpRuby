require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

# The legacy database keeps Kyiv wall-clock time in DATETIME columns, without a zone (the old site, and the Python,
# Java and .NET versions read and write it that way). ActiveRecord's :local mode uses the process time zone, so the
# process runs in Kyiv time whatever zone the server or the CI machine has.
ENV["TZ"] = "Europe/Kyiv"

module NewErpRuby
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Kyiv"
    config.active_record.default_timezone = :local

    # db/structure.sql keeps what schema.rb cannot: MyISAM tables, enum columns, composite keys of the legacy schema.
    config.active_record.schema_format = :sql

    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.test_framework :rspec
      g.helper false
      g.assets false
      g.system_tests nil
    end
  end
end
