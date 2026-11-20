# The legacy tables come from the reference project's DDL (db/reference_schema.sql), not from Ruby migrations:
# the database is shared with the Python, Java and .NET versions, so its structure must stay byte for byte the same.
# NewErpRuby's own tables (erp_* prefix) get normal migrations after this one.
class LoadReferenceSchema < ActiveRecord::Migration[8.1]
  def up
    statements.each { |sql| execute(sql) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # Trilogy runs one statement per call. Whole-line comments go first, then the script splits at a ";" that ends a
  # line (checked: no inline comment in the file ends with ";").
  def statements
    Rails.root.join("db/reference_schema.sql").read
         .lines.reject { |line| line.lstrip.start_with?("--") }.join
         .split(/;\s*$/).map(&:strip).reject(&:empty?)
  end
end
