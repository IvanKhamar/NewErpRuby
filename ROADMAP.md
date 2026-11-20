# Roadmap after the brief (phases 7+)

Phases 1–6 (PLAN.md) finished the original brief. These phases come from the follow-up: a React + TypeScript
interface (the job posting lists it as a plus), more modules of the reference, and polish. Each phase ends like the
earlier ones: green checks, a PR, LEARNING.md and PROGRESS.md updated.

| Phase | What | Done when |
|---|---|---|
| 7 ✅ | **React + TypeScript foundation:** Vite app in `frontend/`, types generated from `docs/openapi.json`, typed API client, login, orders list with filters and paging, order card with the status change. Tests (Vitest, Testing Library, MSW), ESLint, `tsc`, a CI job, a compose service, Rails serves the build at `/ui`. | a manager can log in at `/ui` and change an order status; CI runs the frontend checks |
| 8 | **React: stock, production, refunds.** Stock list with adjustments, production models with operations, the refund recipient check with the confirm step for a close match. The refund endpoints get their own OpenAPI file (`docs/refunds-openapi.json`) so the frontend types and the request specs cover them too. | the three modules work in `/ui`; refund specs validate against the new file |
| 9 | **Port: returns and purchase orders** (`/returns`, `/stock/purchase-orders`): the after-sales and the supply side of the reference, with their status flows. | contract specs for the ported endpoints |
| 10 | **Port: catalog basics** (`/catalog/products` list and card, prices, the sort by sales) and the remaining reports (`/reports/products`, `/reports/statuses`, `/reports/dashboard`). | contract specs; the dashboard shown in `/ui` |
| 11 | **Port: cashbox shifts and reports** (open and close a shift, X/Z reports with Checkbox), bank payment auto-linking, the SMS waybill check. Closes the gaps D15 left. | WebMock specs for every new Checkbox call |
| 12 | **Polish for showing the project:** a production Dockerfile (multi-stage, non-root, `bin/rails assets:precompile`), screenshots and a short demo GIF in the README, a "how to read this code" guide for reviewers. | `docker build` in CI; README with pictures |

## Phase 7 design

- **Where:** `frontend/` in this repository (one PR shows the API and the UI that uses it).
- **Stack:** Vite 8, React 19, TypeScript 6 (typescript-eslint does not support 7 yet), React Router, TanStack
  Query for server state, `openapi-typescript` + `openapi-fetch` for a client typed by the contract.
- **Login:** the same `newerp.auth` cookie as the API. The dev server proxies the API, so the browser sees one
  origin and the SameSite=Strict cookie works without CORS.
- **Serving:** `npm run build` writes to `public/ui`, and Rails serves it (a catch-all route returns `index.html` for
  client-side routes). The build is not committed; the compose service `ui` runs the dev server on port 5173.
- **Tests:** Vitest + Testing Library; MSW answers the API in tests, so they do not need Rails.
