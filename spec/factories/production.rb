FactoryBot.define do
  factory :production_model do
    sequence(:name) { |n| "Сукня #{n}" }
    type { ProductionModel::CLOTHING }
    min_total { 10 }
    sort_order { 0 }
    status { true }
  end

  factory :production_size do
    model factory: :production_model
    size_name { "M" }
    percent { 0 }
    cut_stock { 0 }
    sewn_stock { 0 }
    sort_order { 0 }
  end

  factory :production_component do
    model factory: :production_model
    sequence(:name) { |n| "Деталь #{n}" }
    sort_order { 0 }
  end

  factory :warehouse do
    name { "Шоурум" }
    description { "" }
  end
end
