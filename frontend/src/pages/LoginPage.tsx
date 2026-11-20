import { useState, type FormEvent } from "react";
import { Navigate } from "react-router";
import { ApiError } from "../api/client";
import { useCurrentUser, useLogin } from "../auth";

export function LoginPage() {
  const { data: user } = useCurrentUser();
  const login = useLogin();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  if (user) return <Navigate to="/orders" replace />;

  const submit = (event: FormEvent) => {
    event.preventDefault();
    login.mutate({ username, password });
  };

  return (
    <section className="narrow">
      <h1>Вхід</h1>
      <form onSubmit={submit}>
        <label htmlFor="username">Логін</label>
        <input id="username" autoComplete="username" required value={username} onChange={(e) => setUsername(e.target.value)} />
        <label htmlFor="password">Пароль</label>
        <input id="password" type="password" autoComplete="current-password" required value={password} onChange={(e) => setPassword(e.target.value)} />
        <button type="submit" disabled={login.isPending}>Увійти</button>
      </form>
      {login.error && <p className="flash error" role="alert">{loginMessage(login.error)}</p>}
    </section>
  );
}

// The API tells why: a wrong password (401) or too many tries with the wait time (429).
function loginMessage(error: Error) {
  if (error instanceof ApiError && error.status === 401) return "Невірний логін або пароль";
  return error.message;
}
