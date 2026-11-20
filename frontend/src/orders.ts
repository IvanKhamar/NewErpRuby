import { useQuery } from "@tanstack/react-query";
import { api, unwrap } from "./api/client";

// Statuses change rarely: one request per session is enough.
export function useStatuses() {
  return useQuery({
    queryKey: ["orders", "statuses"],
    queryFn: async () => unwrap(await api.GET("/orders/statuses")),
    staleTime: Infinity,
  });
}

// The API writes Kyiv wall-clock time without an offset ("2026-11-20T10:15:00"), so it is shown as it is,
// not shifted by the browser's time zone.
export function formatDateTime(value: string) {
  const [date = "", time = ""] = value.split("T");
  const [year, month, day] = date.split("-");
  return `${day}.${month}.${year} ${time.slice(0, 5)}`;
}

export function formatMoney(value: number, currency = "UAH") {
  return `${value.toLocaleString("uk-UA", { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ${currency}`;
}
