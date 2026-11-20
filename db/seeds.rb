# Demo data for the local database: everything is invented with Faker (a port of the reference's tools/devseed.py,
# much smaller). Run with `bin/rails db:seed` on an empty development database.
#
# Logins, all with the password "dev" (a local demo password, not a secret): admin (Admin), sklad (Storekeeper),
# manager1, manager2 (Manager).
abort "Seeds are for the development database only." unless Rails.env.development?
abort "The database already has orders; seeds run only once." if Order.exists?

Faker::Config.locale = "uk"
Faker::Config.random = Random.new(42) # the same demo data on every machine
hasher = PasswordHasher.new
lang = ErpSettings.language_id

STATUSES = {
  1 => ["Нове", "#5b8def"], 17 => ["Очікує оплату", "#f2a93b"], 18 => ["Прийнято", "#3aa76d"],
  19 => ["Відмінено", "#9aa0a6"], 20 => ["Пакується", "#8e6bd8"], 22 => ["Відправлено", "#2f5bd3"],
  23 => ["Терміново", "#e5484d"], 24 => ["Отримано", "#1f8f5f"]
}.freeze
STATUSES.each do |id, (name, color)|
  OrderStatus.create!(order_status_id: id, language_id: lang, name:, color:)
end
%w[Сайт Instagram Дзвінок].each.with_index(1) do |name, id|
  OrderSource.create!(order_source_id: id, language_id: lang, name:)
end

staff = { "admin" => "Admin", "sklad" => "Storekeeper", "manager1" => "Manager", "manager2" => "Manager" }
users = staff.map do |username, role|
  user = User.create!(username:, firstname: Faker::Name.first_name, lastname: Faker::Name.last_name,
                      email: "#{username}@example.com", status: true, user_group_id: 0, date_added: Time.current)
  UserLogin.create!(user_id: user.id, role:, password_hash: hasher.hash("dev"), security_stamp: UserLogin.new_stamp)
  user
end
managers = users.select { |u| u.role == "Manager" }

# Catalog: dresses with sizes S, M, L.
sizes = { "S" => 1, "M" => 2, "L" => 3 }
OptionDescription.create!(option_id: 11, language_id: lang, name: "Розмір")
sizes.each { |name, id| OptionValueDescription.create!(option_value_id: id, option_id: 11, language_id: lang, name:) }
products = Array.new(6) do |i|
  product = Product.create!(model: "D-#{100 + i}", price: rand(900..2400), quantity: 0, status: true,
                            date_added: Time.current)
  ProductDescription.create!(product_id: product.id, language_id: lang, name: "Сукня #{Faker::Color.color_name}")
  sizes.each_value do |value_id|
    ProductOptionValue.create!(product_id: product.id, product_option_id: product.id, option_id: 11,
                               option_value_id: value_id, quantity: 5, subtract: true, price: 0, price_prefix: "+",
                               points: 0, points_prefix: "+", weight: 0, weight_prefix: "+")
  end
  product
end

# Consumables and production models with BOMs.
fabric_cat = StockCategory.create!(name: "Тканини")
fittings_cat = StockCategory.create!(name: "Фурнітура")
linen = StockItem.create!(name: "Льон", unit: "м", stock: 120, min_stock: 20, price: 280, category: fabric_cat)
StockItem.create!(name: "Віскоза", unit: "м", stock: 15, min_stock: 25, price: 190, category: fabric_cat)
thread = StockItem.create!(name: "Нитки", unit: "шт.", stock: 300, min_stock: 50, price: 12, category: fittings_cat)
products.first(3).each do |product|
  model = ProductionModel.create!(name: product.name, type: ProductionModel::CLOTHING, min_total: 10, sort_order: 0)
  ProductionProduct.create!(production_id: model.id, product_id: product.id)
  sizes.each_with_index do |(name, value_id), i|
    ProductionSize.create!(production_id: model.id, size_name: name, percent: 33.3, sort_order: i,
                           oc_option_value_id: value_id, cut_stock: rand(0..6), sewn_stock: rand(2..12))
  end
  front = ProductionComponent.create!(production_id: model.id, name: "Перед", sort_order: 0)
  ComponentBomLine.create!(component_id: front.id, item_id: linen.id, qty_per_unit: 1.2)
  SewnBomLine.create!(production_id: model.id, component_id: front.id, qty_per_unit: 1)
  SewnBomLine.create!(production_id: model.id, item_id: thread.id, qty_per_unit: 2)
end

# Orders of the last two months.
80.times do
  added = Faker::Time.between(from: 60.days.ago, to: Time.current)
  product = products.sample
  quantity = rand(1..2)
  order = Order.create!(firstname: Faker::Name.first_name, lastname: Faker::Name.last_name,
                        telephone: "+380 #{rand(50..99)} #{rand(100..999)} #{rand(10..99)} #{rand(10..99)}",
                        email: Faker::Internet.email(domain: "example.com"), shipping_method: "Нова Пошта",
                        shipping_city: Faker::Address.city, payment_method: "Накладений платіж",
                        total: product.price * quantity, currency_code: "UAH", currency_value: 1,
                        order_status_id: STATUSES.keys.sample, order_source_id: rand(1..3),
                        date_added: added, date_modified: added)
  OrderProduct.create!(order_id: order.id, product_id: product.id, name: product.name, model: product.model,
                       quantity:, price: product.price, total: product.price * quantity, reward: 10)
  OrderManager.create!(order_id: order.id, user_id: managers.sample.id, assigned_by_user_id: users.first.id,
                       assigned_at: added)
end

puts "Seeded: #{User.count} users, #{Product.count} products, #{StockItem.count} consumables, " \
     "#{ProductionModel.count} models, #{Order.count} orders."
