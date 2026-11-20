# A question and answer of the storefront's FAQ (dd_faq; the texts are in dd_faq_description per language).
class Faq < ApplicationRecord
  EMAIL = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/

  self.table_name = "dd_faq"
  self.primary_key = "faq_id"

  has_one :description, -> { localized }, class_name: "FaqDescription", foreign_key: :faq_id, inverse_of: :faq,
                                          dependent: nil

  scope :sorted, -> { order(:sort_order, :faq_id) }
end
