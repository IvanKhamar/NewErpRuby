# Progress

Where the port stands. If a session is interrupted, work continues from here.

## Phase 1 — core (done, 2026-11-20)

- Rails 8.1.4 / Ruby 4.0.10 app generated and run in Docker (no Ruby on the machine).
- Legacy schema from the reference loaded by a migration; `db/structure.sql`.
- Login (ASP.NET Identity v3 hashes, encrypted cookie, security stamp, throttle), Pundit roles.
- Orders: list, card, statuses, sources, managers, manual order, status change with handlers, rewards.
- Stock: items, create, adjustments with `SELECT … FOR UPDATE`, movements; a two-thread race test.
- Production: models, card, cut / to-sewing / sewn / ship with BOM write-offs, BOM editing; sewn pieces taken and
  returned by order statuses (idempotent).
- Admin pages at `/app` (ERB + Turbo): login, orders, stock, production.
- Seeds with Faker; CI workflow; Dependabot; gitleaks hook and `bin/gitleaks`.
- Checks: 66 RSpec examples, RuboCop, Brakeman (0 warnings), bundler-audit, importmap audit, gitleaks: all green.

**Check by hand:** `docker compose up`, then `docker compose run --rm app bin/rails db:seed`, open
http://localhost:3000/app as `admin` / `dev`.

**Read in LEARNING.md:** phase 1.

- **CI note:** the first CI run on `main` (phase 1 push) failed, so GitHub sent one failure e-mail: the `bin/`
  scripts had no executable bit (created on Windows) and gitleaks-action cannot scan a repository's first push.
  Fixed in PR #1 (merged, green). Since then every push is preceded by a CI run on a fresh Linux clone in
  `ruby:4.0.10` (`tmp/ci-sim.sh`, not committed), which catches file-mode problems the Windows mount hides.

## Phase 2 — scheduled jobs (done, 2026-11-20)

- Sidekiq + sidekiq-cron, schedule in `config/schedule.yml` (Kyiv time); the `sidekiq` compose service loads it.
- Pre-orders: list, set limit and date, settle (guarded UPDATE per size on the MyISAM table); hourly job.
- Competitor prices: competitors, product pages, check now or daily at 07:00; `Regexp` timeout against ReDoS;
  SSRF-safe page fetcher (public IPs only, pinned connection, redirects only within the site).
- Delivery tracking: Nova Poshta client (Faraday, retries, stub without a key), hourly job.
- Checks: 86 RSpec examples, RuboCop, Brakeman (it found a real SQL-injection risk in `exists?` with a raw param,
  fixed), bundler-audit, importmap audit, gitleaks: all green.

**Check by hand:** `docker compose up` starts Sidekiq too; `docker compose logs sidekiq` shows the three cron jobs.

**Read in LEARNING.md:** phase 2.

## Phase 3 — integrations (done, 2026-11-20)

- Clients in `app/clients` on Faraday (timeouts; retries only where a repeat is safe), stubs without keys:
  LiqPay (signed checkout link, status), PrivatBank (statement import, payment list), SMSClub (send, log),
  Checkbox (fiscalize a receipt: sign-in, token renewal on 401, sale), Nova Post International (waybill abroad with
  JWT auth and the customs checks).
- Every client is tested with WebMock only. New ENV names are in `.env.example`.
- Gaps on purpose (DECISIONS.md D15): bank auto-linking, the SMS waybill check, cashbox shifts and reports,
  HS code search.
- Checks: 98 RSpec examples, RuboCop, Brakeman, bundler-audit, importmap audit, gitleaks: all green.

**Check by hand:** with real sandbox keys in `.env` (never committed), try `POST /orders/{id}/liqpay-link` and open
the link; everything else needs real accounts.

**Read in LEARNING.md:** phase 3.

## Phase 4 — reports, Excel, feeds, sanitizing (done, 2026-11-20)

- `GET /reports/sales` (by day, week from Monday, month, year; cancelled orders left out).
- Stocktaking: `GET /stock/stocktaking/sheet.xlsx` (caxlsx), `POST /stock/stocktaking/preview` (roo, raw .xlsx body,
  errors per row), `POST /stock/stocktaking` (one transaction, rows locked, "Інвентаризація" in the log).
- Partner feed `GET /feeds/{code}.xml` (Builder, markups, plain-text descriptions, EAN-13 barcodes).
- HTML sanitizing on save for FAQ answers (`/catalog/faq`).
- Checks: 110 RSpec examples, RuboCop, Brakeman, bundler-audit, importmap audit, gitleaks: all green.

**Check by hand:** download the sheet as `sklad`, fill in "Фактично" in Excel, send it to the preview.

**Read in LEARNING.md:** phase 4.

## Phase 5 — Kafka (done, 2026-11-20)

- `OrderCreated` / `OrderStatusChanged` to topic `newerp.orders` (key = order id) with WaterDrop, after the commit;
  without `NEWERP_KAFKA_BROKERS` the events go to the log. Kafka runs in the compose profile `kafka`.
- Found and fixed on the way: the publisher was never set (`config.x` returns an empty object), which only the
  real Kafka round trip showed (DECISIONS.md D17).
- Checks: 115 RSpec examples, RuboCop, Brakeman, bundler-audit, importmap audit, gitleaks: all green; a real event
  read back with kafka-console-consumer.

**Check by hand:** LEARNING.md phase 5 has the two commands.

## Next

Phase 6: the new refund recipient check (IBAN mod 97, name matching, audit log).
