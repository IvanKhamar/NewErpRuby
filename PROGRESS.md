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

## Next

Phase 3: clients for Nova Post International, LiqPay, PrivatBank, Checkbox, SMSClub.
