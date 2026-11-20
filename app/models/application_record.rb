class ApplicationRecord < ActiveRecord::Base
  include LegacyTable

  primary_abstract_class
end
