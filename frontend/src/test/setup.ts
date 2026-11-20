import "@testing-library/jest-dom/vitest";
import { cleanup } from "@testing-library/react";
import { server } from "./server";

// Every request must be answered by a handler: an unexpected call fails the test instead of reaching a network.
beforeAll(() => server.listen({ onUnhandledFrame: "error" }));
afterEach(() => {
  server.resetHandlers();
  cleanup();
});
afterAll(() => server.close());
