FactoryBot.define do
  factory :order_status do
    sequence(:order_status_id) { |n| 100 + n }
    language_id { ErpSettings.language_id }
    name { "Статус #{order_status_id}" }
    color { "#336699" }
  end

  factory :order_source do
    sequence(:order_source_id) { |n| n }
    language_id { ErpSettings.language_id }
    name { "Instagram" }
  end

  factory :order do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    telephone { "+380 00 000 00 #{rand(10..99)}" }
    email { Faker::Internet.email(domain: "example.com") }
    shipping_method { "Нова Пошта" }
    shipping_city { "Київ" }
    payment_method { "Накладений платіж" }
    total { 1200 }
    currency_code { "UAH" }
    currency_value { 1 }
    order_status_id { 1 }
    order_source_id { 0 }
    date_added { Time.current }
    date_modified { Time.current }
  end

  factory :order_product do
    order
    product_id { 1 }
    name { "Сукня" }
    model { "D-1" }
    quantity { 1 }
    price { 1200 }
    total { 1200 }
    reward { 0 }
  end
end
