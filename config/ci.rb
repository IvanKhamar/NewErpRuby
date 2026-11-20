# The same checks as GitHub Actions (.github/workflows/ci.yml), for a local run before a push:
#   docker compose run --rm app bin/ci
# Each step stops the run on a non-zero exit code. gitleaks runs outside the container (bin/gitleaks).
CI.run do
  step "Database: test schema", "bin/rails db:test:prepare"
  step "Style: RuboCop", "bundle exec rubocop"
  step "Tests: RSpec", "bundle exec rspec"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap vulnerability audit", "bin/importmap audit"
end
