# Models over the old site's OpenCart tables. Many columns there are NOT NULL without a default (OpenCart always
# writes every column), so a new row gets an empty value of the column's type for each such column we leave unset.
# This is data defaulting only; no callback in this app has side effects (no HTTP, SMS or Kafka).
module LegacyTable
  extend ActiveSupport::Concern

  included do
    # Only the old site's dd_* tables: our own erp_* tables have proper defaults, and a missing value there is a bug.
    before_create :fill_required_blanks, if: -> { self.class.table_name.to_s.start_with?("dd_") }
  end

  private

  def fill_required_blanks
    self.class.columns.each do |column|
      # A zero date default ("0000-00-00") reads as nil in Ruby, so a nil value is filled even when a default exists.
      next if column.null || column.name == self.class.primary_key
      next unless self[column.name].nil?

      self[column.name] = blank_value_for(column)
    end
  end

  def blank_value_for(column)
    case column.type
    when :integer, :decimal, :float, :boolean then 0
    when :datetime then Time.current
    when :date then Date.current
    else ""
    end
  end
end
