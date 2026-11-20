import { keepPreviousData, useQuery } from "@tanstack/react-query";
import { useState, type FormEvent } from "react";
import { Link, useSearchParams } from "react-router";
import { api, unwrap } from "../api/client";
import { formatDateTime, formatMoney, useStatuses } from "../orders";

const PAGE_SIZE = 25;

// The filters live in the URL (?search=…&statusId=…&page=…), so a filtered list can be bookmarked and shared,
// and the browser's Back button works.
export function OrdersPage() {
  const [params, setParams] = useSearchParams();
  const search = params.get("search") ?? "";
  const statusId = params.get("statusId");
  const page = Number(params.get("page") ?? "1");
  const [draft, setDraft] = useState(search);
  const statuses = useStatuses();

  const orders = useQuery({
    queryKey: ["orders", { search, statusId, page }],
    queryFn: async () =>
      unwrap(await api.GET("/orders", {
        params: { query: { search: search || undefined, statusId: statusId ? Number(statusId) : undefined, page, pageSize: PAGE_SIZE } },
      })),
    placeholderData: keepPreviousData, // the old page stays visible while the next one loads
  });

  const update = (changes: Record<string, string | null>) => {
    const next = new URLSearchParams(params);
    Object.entries(changes).forEach(([key, value]) => (value ? next.set(key, value) : next.delete(key)));
    setParams(next);
  };

  const submit = (event: FormEvent) => {
    event.preventDefault();
    update({ search: draft.trim() || null, page: null });
  };

  return (
    <>
      <h1>Замовлення</h1>
      <form className="filters" onSubmit={submit}>
        <input aria-label="Пошук" placeholder="№, телефон, ім'я, e-mail" value={draft} onChange={(e) => setDraft(e.target.value)} />
        <select aria-label="Статус" value={statusId ?? ""} onChange={(e) => update({ statusId: e.target.value || null, page: null })}>
          <option value="">Усі статуси</option>
          {statuses.data?.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
        </select>
        <button type="submit">Знайти</button>
      </form>

      {orders.isError && <p className="flash error" role="alert">{orders.error.message}</p>}
      {orders.data && (
        <>
          <table>
            <thead>
              <tr><th>№</th><th>Дата</th><th>Клієнт</th><th>Телефон</th><th>Сума</th><th>Статус</th><th>Менеджер</th></tr>
            </thead>
            <tbody>
              {orders.data.items.map((order) => (
                <tr key={order.id}>
                  <td><Link to={`/orders/${order.id}`}>{order.id}</Link></td>
                  <td>{formatDateTime(order.dateAdded)}</td>
                  <td>{order.customer}</td>
                  <td>{order.telephone}</td>
                  <td className="num">{formatMoney(order.total, order.currencyCode)}</td>
                  <td>{order.statusName}</td>
                  <td>{order.managerName}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <p className="pager">
            Усього: {orders.data.totalCount}.
            {page > 1 && <button type="button" onClick={() => update({ page: String(page - 1) })}>← Попередня</button>}
            {page < orders.data.totalPages && <button type="button" onClick={() => update({ page: String(page + 1) })}>Наступна →</button>}
          </p>
        </>
      )}
    </>
  );
}
