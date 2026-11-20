import { HttpResponse, http } from "msw";
import { setupServer } from "msw/node";
import type { Schemas } from "../api/client";

// A fake API for the tests (Mock Service Worker answers fetch calls), with the contract's own types, so a fake
// answer cannot drift from the real JSON shape without a compile error.
export const manager: Schemas["CurrentUser"] = {
  userId: 2, username: "manager1", fullName: "Олена Коваленко", role: "Manager", mustChangePassword: false,
};

export const statuses: Schemas["OrderStatusDto"][] = [
  { id: 18, name: "Прийнято", color: "#3aa76d" },
  { id: 22, name: "Відправлено", color: "#2f5bd3" },
];

export const order: Schemas["OrderDetails"] = {
  id: 42, dateAdded: "2026-11-20T10:15:00", customer: "Ірина Мельник", telephone: "+380000000042",
  email: "buyer@example.com", shippingMethod: "Нова Пошта", shippingCity: "Київ", shippingAddress: "",
  paymentMethod: "Передплата", comment: "", total: 1500, currencyCode: "UAH", statusId: 18, statusName: "Прийнято",
  sourceId: 1, sourceName: "Сайт", managerId: 2, managerName: "Олена Коваленко",
  products: [{ productId: 7, name: "Сукня Лана", model: "D-7", quantity: 1, price: 1500, total: 1500 }],
  statusHistory: [], dateShipping: null, invoice: null,
};

const listItem: Schemas["OrderListItem"] = {
  id: order.id, dateAdded: order.dateAdded, customer: order.customer, telephone: order.telephone,
  total: order.total, currencyCode: "UAH", statusId: 18, statusName: "Прийнято", sourceName: "Сайт",
  managerId: 2, managerName: "Олена Коваленко",
};

export const handlers = [
  http.get("*/auth/me", () => new HttpResponse(null, { status: 401 })),
  http.post("*/auth/login", async ({ request }) => {
    const body = (await request.json()) as { username: string; password: string };
    if (body.password !== "right-password") {
      return HttpResponse.json({ title: "Невірний логін або пароль", status: 401 }, { status: 401 });
    }
    return HttpResponse.json(manager);
  }),
  http.get("*/orders/statuses", () => HttpResponse.json(statuses)),
  http.get("*/orders", ({ request }) => {
    const search = new URL(request.url).searchParams.get("search");
    const items = search && !listItem.customer.includes(search) ? [] : [listItem];
    return HttpResponse.json({ items, page: 1, pageSize: 25, totalCount: items.length, totalPages: 1 });
  }),
  http.get("*/orders/:orderId", () => HttpResponse.json(order)),
  http.put("*/orders/:orderId/status", () => HttpResponse.json({ warnings: ["Пошитих «Лана» розміру M бракує 1 шт."] })),
];

export const server = setupServer(...handlers);

// Signed in as the manager.
export const signedIn = () => server.use(http.get("*/auth/me", () => HttpResponse.json(manager)));
