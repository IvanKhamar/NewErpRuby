# The OpenCart tables (orders, users, catalog) are MyISAM, which has no transactions: a test's rows there would not
# roll back with the transactional fixtures. After each example the non-empty MyISAM tables are emptied.
# MyISAM keeps an exact row count in information_schema, so finding them is one cheap query.
module MyisamCleanup
  module_function

  def clean
    connection = ActiveRecord::Base.connection
    connection.execute("SET SESSION information_schema_stats_expiry = 0")
    tables = connection.select_values(<<~SQL.squish)
      SELECT table_name FROM information_schema.tables
      WHERE table_schema = DATABASE() AND engine = 'MyISAM' AND table_rows > 0
    SQL
    tables.each { |table| connection.execute("DELETE FROM #{connection.quote_table_name(table)}") }
  end
end

RSpec.configure do |config|
  config.after { MyisamCleanup.clean }
end
