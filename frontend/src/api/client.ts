import createClient from "openapi-fetch";
import type { components, paths } from "./schema";

export type Schemas = components["schemas"];

// One client for the whole app, typed by docs/openapi.json: a wrong path, a missing parameter or a renamed JSON field
// is a compile error, not a runtime surprise. The login cookie goes along by itself (same origin).
// fetch is looked up on every call, not once at import, so a tool that wraps it later (MSW in tests) still works.
export const api = createClient<paths>({
  baseUrl: window.location.origin,
  credentials: "same-origin",
  fetch: (request) => globalThis.fetch(request),
});

// An error answer of the API: Problem Details ({ title, detail, status }) or an empty 401/403.
export class ApiError extends Error {
  readonly status: number;

  constructor(status: number, problem?: { title?: string | null; detail?: string | null }) {
    super(problem?.detail ?? problem?.title ?? `HTTP ${status}`);
    this.status = status;
  }
}

// Returns the data of a successful answer or throws ApiError, so TanStack Query sees failures as errors.
export function unwrap<T>(result: { data?: T; error?: unknown; response: Response }): T {
  if (result.response.ok && result.data !== undefined) return result.data;
  const problem = typeof result.error === "object" && result.error !== null ? (result.error as { title?: string; detail?: string }) : undefined;
  throw new ApiError(result.response.status, problem);
}
