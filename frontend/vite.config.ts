import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

// The Rails API answers on the contract's root paths. In development Vite forwards them to Rails, so the browser
// sees one origin and the SameSite=Strict login cookie works without CORS.
const API_PREFIXES = ["/auth", "/orders", "/stock", "/production", "/preorders", "/competitors", "/delivery",
  "/payments", "/cashbox", "/reports", "/catalog", "/refunds", "/health"];
const apiTarget = process.env.API_URL ?? "http://localhost:3000";

export default defineConfig({
  plugins: [react()],
  base: "/ui/",
  build: { outDir: "../public/ui", emptyOutDir: true },
  server: {
    host: true,
    port: 5173,
    proxy: Object.fromEntries(API_PREFIXES.map((prefix) => [prefix, { target: apiTarget, changeOrigin: false }])),
  },
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test/setup.ts"],
  },
});
