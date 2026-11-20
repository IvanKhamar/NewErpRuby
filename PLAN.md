# NewErpRuby: port plan

The reference is NewErpPython (`F:\PROJECTS\NewErpPython\NewErpPython`): about 40,000 lines of Python, 277 paths and
369 operations in its OpenAPI contract. A full port is not the goal. The brief asks for idiomatic, explainable Rails
over feature count, so every module of the brief is ported with **a focused set of endpoints that keep the exact
contract** (paths, JSON field names, status codes, ProblemDetails titles). Everything not listed here stays a
documented gap (table at the end).

The contract is `docs/openapi.json` (exported from the reference app with `app.openapi()`, unchanged). Request specs
validate every ported endpoint against it with `committee-rails`.

## Modules: reference → Rails → phase

| Reference module (Python) | Rails here | Endpoints kept from the contract | Phase |
|---|---|---|---|
| `api/health.py` | `HealthController` | `GET /health` | 1 |
| `api/auth.py`, `api/security.py`, `application/auth/*`, `infrastructure/auth/password_hasher.py` | `Authentication` concern, `Current`, `User` + `UserLogin` models, `PasswordHasher` (ASP.NET Identity v3 PBKDF2), `LoginThrottle`, `Api::V1::AuthController` | `POST /auth/login`, `POST /auth/logout`, `GET /auth/me`, `POST /auth/change-password` | 1 |
| roles (`Policies` in `api/security.py`) | `app/policies/*` (Pundit) | (used by every controller) | 1 |
| `api/errors.py` | `Api::V1::BaseController` `rescue_from` → ProblemDetails | (all) | 1 |
| `domain/orders.py`, `application/orders/services.py`, `infrastructure/orders/*` | `Order`, `OrderStatus`, `OrderStatusLog`, `OrderProduct`, `OrderSource`, `OrderManager` models; `Orders::ChangeStatus`, `Orders::Create` services; status handlers in `Orders::StatusHandlers` | `GET /orders`, `GET /orders/statuses`, `GET /orders/sources`, `GET /orders/managers`, `GET /orders/{id}`, `POST /orders`, `PUT /orders/{id}/status` | 1 |
| customer bonuses (`application/orders/credits.py`) | `CustomerReward` model, `Orders::Reward` service | `GET /orders/{id}/credits`, `POST /orders/{id}/reward`, `DELETE /orders/{id}/reward` | 1 |
| `domain/stock.py`, `application/stock/services.py` | `StockItem`, `StockLog`, `StockCategory`, `StockSupplier`; `Stock::Adjust` (pessimistic `lock!`) | `GET /stock/items`, `GET /stock/items/{id}`, `POST /stock/items`, `POST /stock/items/{id}/adjustments`, `GET /stock/items/{id}/movements`, `GET /stock/categories` | 1 |
| `domain/production.py`, `application/production/services.py` | `ProductionModel`, `ProductionSize`, `ProductionComponent`, `ComponentStock`, `ComponentBomLine`, `SewnBomLine`, `ProductionLog`; `Production::RecordOperation`, `Production::BomResolver`, `Orders::StatusHandlers::SewnStock` (idempotent write-off for orders) | `GET /production/models`, `GET /production/models/{id}`, `POST /production/models/{id}/cut`, `…/to-sewing`, `…/sewn`, `…/ship`, `PUT /production/components/{id}/bom`, `PUT /production/models/{id}/sewn-bom` | 1 |
| `web/*` (Jinja2 + HTMX at `/app/`) | `Admin::*` controllers, ERB + Turbo at `/app` | login, orders list and card with status change, stock list with adjustments, production models with operations | 1 |
| `tools/devseed.py` | `db/seeds.rb` (Faker, invented data) | | 1 |
| `worker.py` (Celery beat), pre-orders | Sidekiq + `sidekiq-cron` (`config/schedule.yml`); `PreOrders::Settle` + `SettlePreOrdersJob` (hourly) | `GET /preorders`, `POST /preorders/settle` | 2 |
| `domain/competitors.py`, `application/competitors.py` | `Competitor`, `CompetitorLink`, `CompetitorPrice`; `Competitors::PriceExtractor` (`Regexp.timeout`), `Competitors::CheckPrices` + daily job; `PageFetcher` with SSRF guard | `GET /competitors`, `GET /competitors/links`, `POST /competitors/check` | 2 |
| delivery tracking (`application/delivery/services.py`) | `DeliveryDocument` model, `Delivery::RefreshTracking` + hourly job | `POST /delivery/tracking/refresh` | 2 |
| `infrastructure/delivery/nova_post_international.py` | `NovaPost::InternationalClient` | used by the tracking job and `GET /orders/{id}/shipment` | 3 |
| `infrastructure/payments.py` (LiqPay, PrivatBank) | `Liqpay::Client` (signed checkout link and status), `Privatbank::Client` (statements); `BankPayment` model | `GET /orders/{id}/liqpay-link`, `GET /orders/{id}/liqpay-status`, `GET /payments/bank`, `POST /payments/bank/import` | 3 |
| `infrastructure/cashbox/checkbox.py` | `Checkbox::Client`, `Cheque` model, `Cashbox::Fiscalize` | `POST /cashbox/cheques/{id}/fiscalize` | 3 |
| `infrastructure/sms.py` (SMSClub) | `Smsclub::Client`, `SmsLog`, `Sms::SendToOrder` | `POST /orders/{id}/sms` | 3 |
| `application/reports.py` | `Reports::Sales` query object | `GET /reports/sales` | 4 |
| `infrastructure/spreadsheets.py`, stocktaking | `Stock::Sheet` (caxlsx), `Stock::Stocktaking` (roo) | `GET /stock/stocktaking/sheet.xlsx`, `POST /stock/stocktaking` | 4 |
| `domain/partners.py` (XML feeds) | `Partner` model, `Partners::Feed` (Builder XML) | `GET /feeds/{code}.xml` | 4 |
| HTML sanitizing (`nh3`) | `HtmlSanitizer` on `Rails::HTML5::SafeListSanitizer` | where the reference cleans user HTML | 4 |
| `infrastructure/events.py` (aiokafka) | `OrderEvents::Publisher` (WaterDrop) / `LogPublisher`; events published after commit | (side effect of order create / status change) | 5 |
| — (new, not in the reference) | `Refunds::IbanValidator`, `Refunds::NameMatcher`, `Refunds::CheckRecipient`; `erp_refund_known_account`, `erp_refund_recipient_check` | `POST /refunds/recipient-checks` | 6 |

## Technology mapping

| Python reference | Rails here | Gem |
|---|---|---|
| FastAPI routers | controllers in `Api::V1` (paths at the root, as in the contract) | rails |
| Pydantic DTOs | strong parameters + ActiveModel validations; Alba serializers | alba |
| SQLAlchemy 2 async + aiomysql | ActiveRecord over the legacy tables (`self.table_name`, `self.primary_key`) | trilogy |
| own `erp_*` tables | Rails migrations, `db/structure.sql` | rails |
| Celery + beat | Sidekiq + sidekiq-cron, `config/schedule.yml` | sidekiq, sidekiq-cron |
| aiokafka | WaterDrop producer; log publisher without Kafka | waterdrop |
| itsdangerous cookie | Rails encrypted cookie `newerp.auth` | rails |
| roles in `Policies` | Pundit policies | pundit |
| nh3 | `Rails::HTML5::SafeListSanitizer` | rails-html-sanitizer (with rails) |
| `regex` with timeout | `Regexp.timeout` / `Regexp.new(..., timeout:)` | Ruby core |
| openpyxl | roo (read) + caxlsx (write) | roo, caxlsx |
| httpx clients | Faraday with timeouts and retries | faraday, faraday-retry |
| Jinja2 + HTMX | ERB + Turbo | turbo-rails, importmap-rails, stimulus-rails, propshaft |
| pytest | RSpec, FactoryBot, Faker, shoulda-matchers, WebMock | rspec-rails, factory_bot_rails, faker, shoulda-matchers, webmock |
| contract tests | committee-rails against `docs/openapi.json` | committee-rails |
| ruff | RuboCop | rubocop, rubocop-rails, rubocop-rspec, rubocop-performance |
| import-linter | none on purpose (Rails Way, see DECISIONS.md); security: Brakeman, bundler-audit | brakeman, bundler-audit |
| N+1 checks | Bullet in development and test | bullet |
| login throttle in Redis | Rails cache (memory in dev/test, Redis in production) | redis |
| devseed.py | `db/seeds.rb` | faker |

## Rules carried over from NewErpPython

- **Public repo, no secrets**: `.gitignore` from the first commit, `.env.example` with fake or empty values, ENV only
  (no Rails credentials, no `master.key`), gitleaks in a pre-commit hook and in CI, Dependabot.
- **CI permissions** `contents: read`; CI runs with test values only.
- **ProblemDetails** answers with the same `type` links and Ukrainian titles; 401 and 403 with an empty body; a 500
  shows no exception details.
- **Kyiv business time**: the database keeps Kyiv wall-clock time without a zone; `Time.zone = "Kyiv"` and
  `default_timezone :local`-style handling (see DECISIONS.md), never the machine clock in tests.
- **Login**: failed tries are throttled (429 with `Retry-After`), an unknown login is hashed anyway so the answer
  takes as long as for a known one, the security stamp in the cookie is checked on every request.
- **Every endpoint requires a role**; anonymous only on purpose (`/health`, and the partner feed, which the partner's
  site downloads by the partner code, as in the reference).
- **SQL only through ActiveRecord or bound parameters.**
- **Security headers and CSP** like `api/security.py`.
- **Outside services**: without keys a stub answers; tests use WebMock only.
- **Database-first**: the legacy tables are not changed; own tables use the `erp_` prefix and come from migrations.

## Gaps (reference features not ported)

Catalog (products, prices, sort, dictionaries, pictures), marketing (coupons, vouchers, Klaviyo, TikTok), customers
admin, returns, staff, users admin, cashbox shifts and reports, monobank, purchase orders, stock locations and
transfers, sewing plan, production stocktaking and locations, the other reports, remarketing, the admin tools.
They follow the same patterns as the ported modules.
