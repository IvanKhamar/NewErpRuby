import { screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { HttpResponse, http } from "msw";
import { renderApp } from "./test/render";
import { manager, server, signedIn } from "./test/server";

describe("login", () => {
  it("sends a visitor without a session to the login page", async () => {
    renderApp("/orders");

    expect(await screen.findByRole("heading", { name: "Вхід" })).toBeInTheDocument();
  });

  it("shows the API's answer for a wrong password", async () => {
    renderApp("/login");
    const user = userEvent.setup();

    await user.type(await screen.findByLabelText("Логін"), "manager1");
    await user.type(screen.getByLabelText("Пароль"), "wrong-password");
    await user.click(screen.getByRole("button", { name: "Увійти" }));

    expect(await screen.findByRole("alert")).toHaveTextContent("Невірний логін або пароль");
  });

  it("opens the orders after a successful login", async () => {
    renderApp("/login");
    const user = userEvent.setup();

    await user.type(await screen.findByLabelText("Логін"), "manager1");
    await user.type(screen.getByLabelText("Пароль"), "right-password");
    await user.click(screen.getByRole("button", { name: "Увійти" }));

    expect(await screen.findByRole("heading", { name: "Замовлення" })).toBeInTheDocument();
    expect(screen.getByText("Олена Коваленко (Manager)")).toBeInTheDocument();
  });
});

describe("orders", () => {
  beforeEach(signedIn);

  it("lists orders with Kyiv time and money as the API wrote them", async () => {
    renderApp("/orders");

    const row = (await screen.findByRole("link", { name: "42" })).closest("tr");
    expect(row).not.toBeNull();
    expect(within(row as HTMLElement).getByText("20.11.2026 10:15")).toBeInTheDocument();
    expect(within(row as HTMLElement).getByText(/1\s?500,00 UAH/)).toBeInTheDocument();
  });

  it("filters by the search text", async () => {
    renderApp("/orders");
    const user = userEvent.setup();
    await screen.findByRole("link", { name: "42" });

    await user.type(screen.getByLabelText("Пошук"), "Шевчук");
    await user.click(screen.getByRole("button", { name: "Знайти" }));

    expect(await screen.findByText("Усього: 0.")).toBeInTheDocument();
  });

  it("changes the status on the order card and shows the warnings of other modules", async () => {
    renderApp("/orders/42");
    const user = userEvent.setup();

    await user.selectOptions(await screen.findByLabelText("Новий статус"), "22");
    await user.click(screen.getByRole("button", { name: "Змінити статус" }));

    expect(await screen.findByRole("status")).toHaveTextContent("Пошитих «Лана» розміру M бракує 1 шт.");
  });

  it("shows a refused status change as an error", async () => {
    server.use(http.put("*/orders/:orderId/status", () =>
      HttpResponse.json({ title: "Порушено бізнес-правило", detail: "Статусу 22 не існує.", status: 400 }, { status: 400 })));
    renderApp("/orders/42");
    const user = userEvent.setup();

    await user.selectOptions(await screen.findByLabelText("Новий статус"), "22");
    await user.click(screen.getByRole("button", { name: "Змінити статус" }));

    expect(await screen.findByRole("alert")).toHaveTextContent("Статусу 22 не існує.");
  });

  it("does not open the orders for a storekeeper", async () => {
    server.use(http.get("*/auth/me", () => HttpResponse.json({ ...manager, role: "Storekeeper" })));

    renderApp("/orders");

    expect(await screen.findByText("Ваша роль не має доступу до цього розділу.")).toBeInTheDocument();
  });
});
