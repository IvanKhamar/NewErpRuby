# NewErpRuby

Ruby on Rails version of NewErp: an ERP for a sewing workshop and an online clothing store. It works with the same
MySQL schema and keeps the same HTTP API contract as the other versions:

- [NewErpPython](https://github.com/IvanKhamar/NewErpPython) (FastAPI) — the newest and fullest one, the reference
  for this port;
- [NewErpJava](https://github.com/IvanKhamar/NewErpJava) (Spring Boot);
- [NewErp](https://github.com/IvanKhamar/NewErp) (C#/.NET).

One system, four backends, one contract: [docs/openapi.json](docs/openapi.json) is the reference's OpenAPI file,
and the request specs check every ported endpoint against it.

Built with Claude Code as an AI pair programmer; I reviewed and tested the changes.

## Status

| Phase | What | State |
|---|---|---|
| 1 | Rails app, Docker, legacy schema, seeds, login and roles, orders, stock with row locks, BOMs and production, contract tests, admin pages, CI | done |
| 2 | Sidekiq + cron: pre-orders, competitor prices with `Regexp.timeout` and an SSRF-safe fetcher, delivery tracking | done |
| 3 | Clients: Nova Post International, LiqPay, PrivatBank, Checkbox, SMSClub (one flow each, WebMock tests) | done |
| 4 | Sales report, Excel stocktaking (caxlsx + roo), partner XML feed (Builder), HTML sanitizing (FAQ) | done |
| 5 | Order events to Kafka (WaterDrop) | planned |
| 6 | **New module:** refund recipient check (IBAN mod 97 + name matching) | planned |

Tests: 110 examples (the number `bundle exec rspec` prints). The ported endpoints and what is left out are listed in
[PLAN.md](PLAN.md); decisions made on the way are in [DECISIONS.md](DECISIONS.md).

## Stack

Ruby 4.0.10 · Rails 8.1.4 · MySQL 8.0 (Trilogy driver) · Redis 7 · Sidekiq 8.1 · Hotwire Turbo + importmap ·
Alba · Pundit · RSpec 8 (rspec-rails), FactoryBot, Faker, shoulda-matchers, WebMock, committee-rails ·
RuboCop (rails, rspec, performance) · Brakeman · bundler-audit · gitleaks · Docker Compose · GitHub Actions

## Run it

Everything runs in Docker; no Ruby is needed on the machine (this repo was built on Windows that way).

```
docker compose up                                  # MySQL, Redis, the app and Sidekiq; http://localhost:3000
docker compose run --rm app bin/rails db:seed      # invented demo data (once, on an empty database)
```

Then open http://localhost:3000/app and log in as `admin`, `sklad` or `manager1` with the demo password `dev`
(seed data only). The JSON API answers on the contract's paths, for example `POST /auth/login`, `GET /orders`.

Settings come from environment variables; copy `.env.example` to `.env` to change them. No secret is needed for
development: without keys every outside service is a stub, and tests never leave the machine (WebMock).

## Tests and checks

```
docker compose run --rm app bin/ci                 # the CI steps: schema, RuboCop, RSpec, Brakeman, gem and importmap audits
docker compose run --rm app bundle exec rspec      # only the tests
bin/gitleaks                                       # secret scan of the whole history (Docker)
git config core.hooksPath .githooks                # once per clone: gitleaks on every commit
```

## Structure

```
app/
  models/        ActiveRecord models over the legacy tables, scopes, rules of one entity (StockItem#adjust)
  services/      operations over several models: Orders::ChangeStatus, Stock::Adjust, Production::RecordOperation
  policies/      Pundit: which role may use which module
  serializers/   Alba: the JSON shapes of the contract
  controllers/
    api/v1/      JSON API (paths at the root, as in the contract)
    admin/       HTML admin pages at /app (ERB + Turbo), calling the same services
lib/             PasswordHasher (ASP.NET Identity v3 format), LoginThrottle
db/
  reference_schema.sql   the reference's table DDL, loaded by the first migration
  structure.sql          the full schema (legacy tables + own migrations)
spec/            requests (with contract checks), services, models
```

## How it differs from the Python version, and why

| Python reference | Here | Why |
|---|---|---|
| Layers `domain → application → infrastructure → api`, checked by import-linter | Models, services, policies, serializers: the Rails Way | Rails teams expect Rails conventions; a single-entity rule lives in its model, a multi-model operation in a service with one `call` |
| Business errors as exceptions mapped to HTTP | Services return an explicit `Result`; `rescue_from` stays for the rest | The controller shows clearly what happens on success and on failure |
| Compare-and-set on the stock quantity (409 on a race) | `SELECT … FOR UPDATE` (`lock`) in a transaction | Asked for by the brief, like the Java version; the second change waits instead of failing |
| itsdangerous-signed cookie | Rails encrypted cookie | Built into Rails; the stamp check per request is the same |
| Status handlers as classes | `Orders::StatusHandlers` objects with `call(change)` | A new reaction to statuses is a new class, no `case` over statuses |
| Celery beat | Sidekiq + sidekiq-cron (phase 2) | The Rails standard for jobs on Redis |

The database is shared by design: the old site's tables are read and written as they are (MyISAM for OpenCart
tables, InnoDB for stock and production), and times are Kyiv wall-clock time without a zone, like in every version.
