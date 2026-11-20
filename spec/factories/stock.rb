FactoryBot.define do
  factory :stock_category do
    sequence(:name) { |n| "Тканини #{n}" }
  end

  factory :stock_item do
    sequence(:name) { |n| "Тканина #{n}" }
    unit { "м" }
    stock { 10 }
    min_stock { 2 }
    price { 150 }
    status { true }
  end
end
