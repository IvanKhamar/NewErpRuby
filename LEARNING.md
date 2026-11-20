# LEARNING.md — Rails на прикладі NewErpRuby

Нотатки для себе: які концепції Rails використано в кожній фазі, де саме в коді, і що про це можуть спитати на
співбесіді. Посилання ведуть на файли цього репозиторію.

---

## Фаза 1. Каркас і ядро

### MVC і маршрутизація

Rails — це MVC: **модель** (дані й правила, `app/models`), **контролер** (приймає запит, викликає логіку, віддає
відповідь, `app/controllers`), **представлення** (HTML-шаблони ERB, `app/views`; для JSON у нас серіалізатори
`app/serializers`). Маршрути описано в [config/routes.rb](config/routes.rb): `scope module: "api/v1"` кладе код у
`Api::V1::…`, але шляхи лишаються як у контракті (`/orders`, а не `/api/v1/orders`). `namespace :admin, path: "app"`
дає HTML-сторінки на `/app`. `resources :orders, only: %i[index show]` — REST-маршрути одним рядком.

**Питання на співбесіді:**
- *Чим `namespace` відрізняється від `scope module:`?* — `namespace :admin` змінює і шлях (`/admin`), і модуль
  контролера, і імена хелперів (`admin_orders_path`); `scope module:` змінює лише модуль, шлях лишається.
- *Що таке RESTful-маршрути в Rails?* — `resources` створює 7 стандартних дій (index, show, new, create, edit,
  update, destroy) з відповідними HTTP-методами; `member`/`collection` додають свої дії.
- *Як подивитися всі маршрути?* — `bin/rails routes` (можна з `-g orders`).

### ActiveRecord і міграції над legacy-таблицями

ActiveRecord — ORM: клас моделі = таблиця, об'єкт = рядок. Таблиці старого сайту мають свої імена й ключі, тому
в моделях [Order](app/models/order.rb), [StockItem](app/models/stock_item.rb) задано `self.table_name` і
`self.primary_key`; для довідників зі складеним ключем — `self.primary_key = %i[order_status_id language_id]`
([OrderStatus](app/models/order_status.rb)). Колонка `type` у Rails зарезервована для STI (наслідування в одній
таблиці), тому в [ProductionModel](app/models/production_model.rb) `self.inheritance_column = nil`.
Схему legacy не змінюємо: перша міграція
[LoadReferenceSchema](db/migrate/20261120000001_load_reference_schema.rb) просто виконує DDL еталону, а
`schema_format = :sql` зберігає все в `db/structure.sql` (schema.rb втратив би MyISAM і enum-колонки).

**Питання:**
- *Навіщо `structure.sql` замість `schema.rb`?* — schema.rb описує схему Ruby-DSL і знає лише загальні типи;
  structure.sql — це дамп SQL, він зберігає специфічне для БД (рушії, тригери, enum, складені ключі).
- *Як працювати з legacy-таблицею, що не відповідає конвенціям?* — `self.table_name`, `self.primary_key`,
  `foreign_key:`/`primary_key:` в асоціаціях, `alias_attribute` для зручних імен, `inheritance_column = nil`.
- *Що робить `db:prepare`?* — створює БД, якщо її немає, і завантажує схему; якщо є — виконує нові міграції.

### Асоціації та scopes

`has_many`, `belongs_to`, `has_one … through:` описують зв'язки ([Order](app/models/order.rb):
`has_one :manager, through: :manager_assignment`). Scope — іменований шматок запиту, який можна поєднувати:
`Order.placed.with_status(18).newest_first`. Scope повертає `Relation`, запит іде в БД лише тоді, коли потрібні
дані (лінива ініціалізація). Асоціація зі scope: `belongs_to :status, -> { localized }` бере назву статусу потрібною
мовою.

**Питання:**
- *Чим scope відрізняється від методу класу?* — майже нічим; але scope завжди повертає Relation (навіть якщо
  умова дала nil), тож ланцюжок не ламається.
- *`belongs_to` обов'язковий за замовчуванням?* — так, з Rails 5 потрібен `optional: true`, якщо зв'язку може не бути
  (у нас: старі таблиці MyISAM без зовнішніх ключів, товар міг зникнути —
  [ProductOptionValue](app/models/product_option_value.rb)).
- *Що таке `inverse_of`?* — підказка Rails, що дві асоціації описують один зв'язок; тоді в пам'яті це той самий
  об'єкт, без зайвого запиту.

### Strong parameters

Контролер явно перелічує, які поля запиту читає: `params.permit(:firstname, …, lines: %i[productId quantity price])`
([Api::V1::OrdersController](app/controllers/api/v1/orders_controller.rb)). Так користувач не підсуне поле, яке
змінить щось зайве (mass assignment). У Rails 8 є `params.expect(:id)` — сувора версія `require`.

**Питання:**
- *Від чого захищають strong parameters?* — від mass assignment: `Model.new(params)` з невідфільтрованими полями
  дозволив би записати, наприклад, `role: "Admin"`.
- *Різниця `require` і `permit`?* — `require` вимагає наявність ключа (інакше 400), `permit` пропускає лише
  перелічені ключі.

### `before_action` і фільтри

`before_action -> { authorize :orders, :manage? }` перевіряє роль перед кожною дією контролера. Логін теж фільтр:
concern [Authentication](app/controllers/concerns/authentication.rb) додає `before_action :require_authentication`,
а `allow_unauthenticated_access only: :login` його вимикає для входу. `after_action :verify_authorized` (Pundit)
падає, якщо дія забула перевірити роль.

**Питання:**
- *Що станеться, якщо `before_action` викличе `render` або `redirect_to`?* — ланцюжок зупиниться, дія не виконається.
- *Що таке concern?* — модуль з `ActiveSupport::Concern`, який підключають у кілька класів (`included do … end`
  для макросів класу, `class_methods do … end` для методів класу).

### Колбеки і чому їх мало

Колбеки моделі (`before_save`, `after_commit`) зручні, але приховують побічні ефекти: хтось зберігає замовлення —
і несподівано йде SMS. Тому тут колбек один: [LegacyTable](app/models/concerns/legacy_table.rb) лише заповнює
порожні значення NOT NULL-колонок старих таблиць (дані, без побічних ефектів). SMS, Kafka, HTTP — тільки в сервісах
і задачах. Події в Kafka йдуть після коміту транзакції: `ActiveRecord.after_all_transactions_commit`
([OrderEvents](app/services/order_events.rb)).

**Питання:**
- *Чому не надсилати лист в `after_save`?* — транзакцію можуть відкотити, а лист уже пішов; плюс тести й імпорти
  ненавмисно запускають побічні ефекти. Якщо колбек — то `after_commit`, а краще явний виклик у сервісі.
- *Порядок колбеків при `save`?* — before_validation → validate → after_validation → before_save → before_create/update
  → after_create/update → after_save → (після коміту) after_commit.

### Транзакції та блокування

[Stock::Adjust](app/services/stock/adjust.rb): `StockItem.transaction { StockItem.lock.find_by(…) }` — це
`SELECT … FOR UPDATE`: другий запит на той самий рядок чекає, поки перша транзакція закінчиться, і бачить уже новий
залишок. Тест [adjust_call_spec.rb](spec/services/stock/adjust_call_spec.rb) запускає дві зміни в двох потоках і
перевіряє, що жодна не загубилася. Рядки блокуються в одному порядку (за id), щоб не було дедлоків
([Production::RecordOperation](app/services/production/record_operation.rb)). Важливо: таблиці OpenCart — MyISAM,
транзакцій у них немає; таблиці складу — InnoDB, тому блокування там працює.

**Питання:**
- *Песимістичне vs оптимістичне блокування?* — песимістичне (`lock`, `with_lock`) блокує рядок у БД, інші чекають;
  оптимістичне (`lock_version`) нічого не блокує, а при конфлікті кидає `StaleObjectError`, і дію повторюють.
  Песимістичне — коли конфлікти часті й коротка транзакція; оптимістичне — коли конфлікти рідкі.
- *Що робить `with_lock`?* — відкриває транзакцію і перечитує рядок з `FOR UPDATE` (`lock!` усередині).
- *Чи відкочується транзакція, якщо кинути виняток?* — так, будь-який виняток з блоку `transaction` робить ROLLBACK
  і летить далі; `ActiveRecord::Rollback` відкочує мовчки.

### N+1 і `includes`

N+1 — коли список зі 100 замовлень робить ще 100 запитів за статусом кожного. `includes(:status, :manager)`
підвантажує зв'язки кількома запитами наперед ([Api::V1::OrdersController#index](app/controllers/api/v1/orders_controller.rb)).
Gem **Bullet** у тестах падає при N+1 (і при зайвому `includes`): так знайшлися два місця в цій фазі.

**Питання:**
- *`includes` vs `preload` vs `eager_load`?* — `preload` завжди окремі запити; `eager_load` — один запит з LEFT JOIN;
  `includes` сам вибирає (JOIN, якщо на підвантажену таблицю є умова `references`/`where`).
- *Як знайти N+1?* — логи (повторювані SELECT), Bullet, `strict_loading`.

### Pundit (ролі)

Політики в `app/policies`: [OrdersPolicy](app/policies/orders_policy.rb) — `manage?` для Admin і Manager.
Контролер викликає `authorize :orders, :manage?`; при відмові Pundit кидає `NotAuthorizedError`, а `rescue_from`
перетворює це на 403 без тіла (як у .NET). Меню адмінки показує ролі лише її модулі (`allowed?`).

**Питання:**
- *Що таке headless policy?* — політика без запису: `authorize :orders` замість `authorize @order`; підходить, коли
  роль відкриває весь модуль.
- *Як не забути перевірку?* — `after_action :verify_authorized` кидає помилку, якщо дія не викликала `authorize`.

### RSpec і FactoryBot

Тести в `spec/`: request specs б'ють по HTTP і перевіряють відповідь проти контракту (`expect_contract(200)` з
[spec/support/contract.rb](spec/support/contract.rb), committee-rails). FactoryBot будує дані:
`create(:order, order_status_id: 18)` ([spec/factories](spec/factories)). Транзакційні фікстури відкочують дані
після кожного тесту — але MyISAM не відкочується, тому [myisam_cleanup.rb](spec/support/myisam_cleanup.rb)
чистить ці таблиці.

**Питання:**
- *`let` vs `let!`?* — `let` лінивий (створюється при першому зверненні), `let!` — перед кожним тестом; якщо об'єкт у
  тесті не використовується, краще `before { create(...) }`.
- *`build` vs `create` у FactoryBot?* — `build` не зберігає в БД (швидше), `create` зберігає.
- *Чим request spec відрізняється від controller spec?* — request spec проходить весь стек (маршрути, middleware,
  cookie); controller specs у нових проєктах не рекомендують.

### Сервіси й Result

Логіка на кілька моделей — у `app/services`, один публічний метод `call`, явний результат
([ApplicationService](app/services/application_service.rb)): `result.success?`, `result.value`, `result.error`.
Правило однієї сутності — у моделі (`StockItem#adjust`), воно кидає `DomainError`, а `ApplicationService.call`
перетворює його на помилку після відкату транзакції.

**Питання:**
- *Навіщо service objects, якщо є «fat model»?* — коли операція зачіпає кілька моделей (замовлення + склад + журнал),
  у жодній моделі їй не місце; сервіс легко тестувати й викликати з API, HTML і задачі.

---

## Що прочитати після фази 1

1. [config/routes.rb](config/routes.rb) → [Api::V1::OrdersController](app/controllers/api/v1/orders_controller.rb)
   → [Orders::ChangeStatus](app/services/orders/change_status.rb) → [SewnStock](app/services/orders/status_handlers/sewn_stock.rb).
2. [Stock::Adjust](app/services/stock/adjust.rb) і тест з потоками [adjust_call_spec.rb](spec/services/stock/adjust_call_spec.rb).
3. [Authentication](app/controllers/concerns/authentication.rb) і [PasswordHasher](lib/password_hasher.rb).

---

## Фаза 2. Задачі за розкладом

### ActiveJob і Sidekiq

ActiveJob — спільний інтерфейс фонових задач у Rails (`perform_later`, `retry_on`, `queue_as`); Sidekiq — один із
«бекендів», який зберігає задачі в Redis і виконує їх в окремому процесі (сервіс `sidekiq` у
[docker-compose.yml](docker-compose.yml)). Адаптер задано в [config/application.rb](config/application.rb):
`config.active_job.queue_adapter = :sidekiq`; у тестах — `:test` ([config/environments/test.rb](config/environments/test.rb)).
Задачі тонкі: [SettlePreOrdersJob](app/jobs/settle_pre_orders_job.rb) лише викликає сервіс і пише в лог.
[RefreshDeliveryTrackingJob](app/jobs/refresh_delivery_tracking_job.rb) повторюється при збої сервісу:
`retry_on NovaPoshta::Client::Error, wait: :polynomially_longer, attempts: 5`.

**Питання:**
- *Чому задача має бути тонкою та ідемпотентною?* — Sidekiq гарантує «принаймні один раз»: задачу можуть виконати
  двічі (рестарт процесу, повтор після помилки). Логіка в сервісі, який можна безпечно повторити (наш settle —
  compare-and-set, тож повтор нічого не зіпсує).
- *Що передавати в аргументах задачі?* — прості значення (id), не ActiveRecord-об'єкти: задача може виконатися
  пізніше, коли запис уже змінився (ActiveJob уміє GlobalID, але id надійніший і явний).
- *`perform_now` vs `perform_later`?* — `perform_now` виконує одразу в поточному процесі (зручно в тестах),
  `perform_later` кладе в чергу.

### Розклад: sidekiq-cron

[config/schedule.yml](config/schedule.yml) описує cron-рядки з часовим поясом (`0 7 * * * Europe/Kyiv`),
[config/initializers/sidekiq.rb](config/initializers/sidekiq.rb) завантажує їх при старті Sidekiq. Це аналог
Celery beat в еталоні.

**Питання:**
- *Що буде, якщо запущено три процеси Sidekiq — задача виконається тричі?* — ні, sidekiq-cron ставить задачу в
  чергу один раз (блокування в Redis), а виконає її один із процесів.

### Транзакції на MyISAM: compare-and-set

Таблиця розмірів `dd_product_option_value` — MyISAM: транзакцій і блокувань рядків немає. Тому
[PreOrders::Settle](app/services/pre_orders/settle.rb) оновлює кожен розмір одним `UPDATE … WHERE quantity = старе
AND pre_order_quantity = старе`. Якщо вітрина встигла продати ще, рядок не зміниться і буде врахований наступного
разу. `update_all` повертає кількість змінених рядків — так рахуємо результат.

**Питання:**
- *Як уникнути lost update без транзакцій?* — умовний UPDATE зі старими значеннями (compare-and-set) або
  колонка версії (оптимістичне блокування); перевіряти кількість змінених рядків.

### Regexp з таймаутом (захист від ReDoS)

Вираз для ціни пише людина, а сторінку — чужий сайт. «Поганий» вираз може шукати збіг роками (катастрофічний
backtracking). Ruby 3.2+ має `Regexp.new(pattern, timeout: 2.0)`, який кидає `Regexp::TimeoutError`
([PriceExtractor](app/services/competitors/price_extractor.rb)). Цікаво: Ruby 3.2 ще й мемоізує більшість виразів,
тож класичний `(a+)+$` уже не зависає; зависають вирази зі зворотними посиланнями (`\1`) — саме такий у тесті
[price_extractor_spec.rb](spec/services/competitors/price_extractor_spec.rb).

**Питання:**
- *Що таке ReDoS?* — відмова в обслуговуванні через регулярний вираз з експоненційним перебором; захист — таймаут,
  обмеження довжини виразу й тексту, вирази без вкладених квантифікаторів.

### SSRF

Адресу сторінки конкурента вводить користувач, а запит робить сервер — значить, через неї можна було б звернутися
до внутрішньої мережі (наприклад, до `169.254.169.254` — метаданих хмари). [PageFetcher](app/services/competitors/page_fetcher.rb)
спершу резолвить DNS і пускає лише публічні адреси, з'єднується саме з перевіреною IP (`Net::HTTP#ipaddr`, захист від
DNS rebinding), редиректи — тільки в межах сайту конкурента.

**Питання:**
- *Що таке SSRF і як від нього захиститися?* — Server-Side Request Forgery: сервер робить запит на адресу від
  нападника. Захист: allowlist доменів/схем, заборона приватних і службових IP після резолву, без автоматичних
  редиректів, таймаути й ліміт розміру відповіді.

### HTTP-клієнти: Faraday

[NovaPoshta::Client](app/clients/nova_poshta/client.rb): Faraday з middleware `:json` (тіло запиту/відповіді),
`:retry` (повтори з експоненційною паузою для 429/5xx) і таймаутами. Без ключа — `Stub`, тож локально нічого не йде
в реальний сервіс. У тестах WebMock (`stub_request`) підміняє HTTP, а `WebMock.disable_net_connect!` падає на будь-
якому незаглушеному запиті.

**Питання:**
- *Навіщо таймаути на кожен зовнішній виклик?* — без них один повільний сервіс займає потоки Puma/Sidekiq і
  «кладе» весь застосунок.
- *Чи безпечно повторювати POST?* — лише якщо операція ідемпотентна (у нас tracking — читання), інакше потрібен
  ключ ідемпотентності.

---

## Фаза 3. Інтеграції з зовнішніми сервісами

### Клієнти в `app/clients`

Кожен сервіс має свій клас-клієнт: [Liqpay::Client](app/clients/liqpay/client.rb),
[Privatbank::Client](app/clients/privatbank/client.rb), [Smsclub::Client](app/clients/smsclub/client.rb),
[Checkbox::Client](app/clients/checkbox/client.rb), [NovaPost::InternationalClient](app/clients/nova_post/international_client.rb).
Спільне налаштування Faraday — у [HttpClient](app/clients/http_client.rb): JSON, таймаути, повтори. Клієнт нічого
не знає про ActiveRecord: він отримує дані й повертає прості об'єкти (`Data.define`). Бізнес-рішення — у сервісах
(`app/services/payments`, `cashbox`, `sms`, `delivery`). Метод `self.build` читає ключі з ENV і, якщо їх немає,
повертає заглушку (`Stub`) — тому локально й у тестах нічого не йде в реальні сервіси.

**Питання:**
- *Як ізолювати зовнішній API, щоб його легко було підмінити в тестах?* — окремий клас-клієнт з малим інтерфейсом,
  передача його в сервіс через аргумент (`client: Liqpay::Client.build` за замовчуванням, у тесті — інший об'єкт),
  WebMock для HTTP-рівня.
- *Які запити можна повторювати автоматично?* — ідемпотентні (GET, читання статусу). Продаж у касі, створення ТТН,
  надсилання SMS — ні: повтор зробить дубль. Тому `retry` у Faraday увімкнено лише для GET (і для POST-читання в
  Новій Пошті, з коментарем чому).
- *Що робити з токеном, який протух?* — як у Checkbox і Nova Post International: на 401 один раз отримати новий
  токен і повторити запит, вдруге — помилка.

### Підпис запитів (LiqPay)

LiqPay перевіряє, що посилання на оплату створив саме магазин: `data` = base64(JSON), `signature` =
base64(SHA1(private_key + data + private_key)). Закритий ключ ніколи не йде в браузер; змінити суму в посиланні
не можна — підпис перестане збігатися.

**Питання:**
- *Навіщо підписувати запит, якщо є HTTPS?* — HTTPS захищає канал, але не захищає від того, що користувач сам змінить
  параметри (суму) у посиланні; підпис (HMAC/хеш із секретом) — від цього.

### Гроші в копійках, текст як в OpenCart

Checkbox приймає суми в копійках, кількість — у тисячних ([FiscalReceipt](app/models/fiscal_receipt.rb)); округлення
`round(half: :up)`. Стара таблиця банківських оплат зберігає суми текстом ("1500.00 UAH"),
[BankPayment](app/models/bank_payment.rb) читає й пише їх у тому ж форматі. Ніколи `Float` для грошей: лише
`BigDecimal` (у JSON — число, як вимагає контракт).

**Питання:**
- *Чому не Float для грошей?* — двійкова дробова арифметика: 0.1 + 0.2 ≠ 0.3; для грошей — BigDecimal або цілі копійки.

### Секрети з ENV, а не з таблиці

Стара таблиця касирів `dd_cashbox_user` містить логіни й ключі Checkbox відкритим текстом. Модель
[Cashier](app/models/cashier.rb) прибирає ці колонки з ActiveRecord (`ignored_columns`), а ключі береться з
`NEWERP_CHECKBOX_CASHIERS` (див. [.env.example](.env.example)).

**Питання:**
- *Що таке `ignored_columns`?* — ActiveRecord поводиться так, ніби колонки немає: не читає її в SELECT *, не створює
  атрибут; зручно для legacy-колонок, які не можна видалити.

### Alba і методи серіалізатора

Alba викликає метод серіалізатора, якщо його ім'я збігається з атрибутом. Помічник `number(...)` конфліктував з
атрибутом `number` (номер ТТН) — тому помічники називаються `json_number` і `json_time`
([ApplicationSerializer](app/serializers/application_serializer.rb)). Урок: тест на кожен ендпоінт ловить такі речі.
