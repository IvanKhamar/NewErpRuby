import { Link, Navigate, Outlet, createBrowserRouter } from "react-router";
import { canUseOrders, useCurrentUser, useLogout } from "./auth";
import { LoginPage } from "./pages/LoginPage";
import { OrderPage } from "./pages/OrderPage";
import { OrdersPage } from "./pages/OrdersPage";

// Pages behind the login: without a session the user goes to /login; a role without the module sees a message
// (the API would answer 403 anyway; this only saves a useless request).
function SignedInLayout() {
  const { data: user, isPending } = useCurrentUser();
  const logout = useLogout();

  if (isPending) return <p>Завантаження…</p>;
  if (!user) return <Navigate to="/login" replace />;

  return (
    <>
      <header className="topbar">
        <strong>NewErp</strong>
        <nav>{canUseOrders(user) && <Link to="/orders">Замовлення</Link>}</nav>
        <span className="who">
          {user.fullName} ({user.role})
          <button type="button" className="link" onClick={() => logout.mutate()}>Вийти</button>
        </span>
      </header>
      <main>{canUseOrders(user) ? <Outlet /> : <p>Ваша роль не має доступу до цього розділу.</p>}</main>
    </>
  );
}

export const routes = [
  { path: "/login", element: <main><LoginPage /></main> },
  {
    element: <SignedInLayout />,
    children: [
      { path: "/", element: <Navigate to="/orders" replace /> },
      { path: "/orders", element: <OrdersPage /> },
      { path: "/orders/:orderId", element: <OrderPage /> },
    ],
  },
];

export const createRouter = () => createBrowserRouter(routes, { basename: "/ui" });
