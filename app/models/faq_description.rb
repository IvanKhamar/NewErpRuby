# The question (name) and the answer (description, HTML) of an FAQ entry in one language.
class FaqDescription < ApplicationRecord
  self.table_name = "dd_faq_description"
  self.primary_key = %i[faq_id language_id]

  belongs_to :faq, inverse_of: :description

  scope :localized, -> { where(language_id: ErpSettings.language_id) }
end
