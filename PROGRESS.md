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

## Next

Phase 2: Sidekiq + sidekiq-cron, pre-orders, competitor prices with `Regexp.timeout`, delivery tracking.
