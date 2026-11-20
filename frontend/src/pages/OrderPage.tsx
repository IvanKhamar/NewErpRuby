import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { Link, useParams } from "react-router";
import { api, unwrap } from "../api/client";
import { formatDateTime, formatMoney, useStatuses } from "../orders";

export function OrderPage() {
  const orderId = Number(useParams().orderId);
  const queryClient = useQueryClient();
  const statuses = useStatuses();
  const [statusId, setStatusId] = useState<number>();

  const order = useQuery({
    queryKey: ["orders", orderId],
    queryFn: async () => unwrap(await api.GET("/orders/{order_id}", { params: { path: { order_id: orderId } } })),
  });

  // The status change runs the same service as the API and the admin pages; warnings come from other modules
  // (for example, too few sewn pieces), so they are shown, not treated as errors.
  const changeStatus = useMutation({
    mutationFn: async (newStatusId: number) =>
      unwrap(await api.PUT("/orders/{order_id}/status", {
        params: { path: { order_id: orderId } },
        body: { statusId: newStatusId },
      })),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["orders"] }),
  });

  if (order.isPending) return <p>Завантаження…</p>;
  if (order.isError) return <p className="flash error" role="alert">{order.error.message}</p>;

  const o = order.data;
  const selected = statusId ?? o.statusId;

  return (
    <>
      <h1>Замовлення №{o.id}</h1>
      <div className="grid">
        <section>
          <h2>Клієнт</h2>
          <p>{o.customer}<br />{o.telephone}<br />{o.email}</p>
          <p>{o.shippingMethod}: {o.shippingCity} {o.shippingAddress}</p>
          <p>{o.paymentMethod}</p>
          {o.comment && <p className="muted">{o.comment}</p>}
        </section>
        <section>
          <h2>Статус</h2>
          <p><strong>{o.statusName}</strong> · {o.sourceName} · {o.managerName}</p>
          <select aria-label="Новий статус" value={selected} onChange={(e) => setStatusId(Number(e.target.value))}>
            {statuses.data?.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
          <button type="button" disabled={selected === o.statusId || changeStatus.isPending} onClick={() => changeStatus.mutate(selected)}>
            Змінити статус
          </button>
          {changeStatus.isError && <p className="flash error" role="alert">{changeStatus.error.message}</p>}
          {changeStatus.data && (
            <p className={changeStatus.data.warnings.length ? "flash warn" : "flash ok"} role="status">
              {changeStatus.data.warnings.length ? changeStatus.data.warnings.join(" ") : "Статус змінено."}
            </p>
          )}
        </section>
      </div>

      <h2>Товари</h2>
      <table>
        <thead><tr><th>Товар</th><th>Модель</th><th>К-сть</th><th>Ціна</th><th>Сума</th></tr></thead>
        <tbody>
          {o.products.map((line, index) => (
            <tr key={index}>
              <td>{line.name}</td><td>{line.model}</td><td className="num">{line.quantity}</td>
              <td className="num">{formatMoney(line.price, o.currencyCode)}</td>
              <td className="num">{formatMoney(line.total, o.currencyCode)}</td>
            </tr>
          ))}
        </tbody>
        <tfoot><tr><td colSpan={4}>Разом</td><td className="num">{formatMoney(o.total, o.currencyCode)}</td></tr></tfoot>
      </table>

      <h2>Історія статусів</h2>
      <ul>
        {o.statusHistory.map((entry, index) => (
          <li key={index}>{formatDateTime(entry.changedAt)} — {entry.newStatusName ?? entry.newStatusId} ({entry.userName})</li>
        ))}
      </ul>
      <p><Link to="/orders">← До списку</Link></p>
    </>
  );
}
