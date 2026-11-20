class OptionValueDescription < ApplicationRecord
  self.table_name = "dd_option_value_description"
  self.primary_key = %i[option_value_id language_id]

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
