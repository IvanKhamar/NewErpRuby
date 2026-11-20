import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ApiError, api, unwrap, type Schemas } from "./api/client";

export type CurrentUser = Schemas["CurrentUser"];

const ME = ["auth", "me"] as const;

// Who is signed in: null when the API answers 401 (no session or it ended).
export function useCurrentUser() {
  return useQuery({
    queryKey: ME,
    queryFn: async (): Promise<CurrentUser | null> => {
      try {
        return unwrap(await api.GET("/auth/me"));
      } catch (error) {
        if (error instanceof ApiError && error.status === 401) return null;
        throw error;
      }
    },
    staleTime: 60_000,
  });
}

export function useLogin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (credentials: { username: string; password: string }) =>
      unwrap(await api.POST("/auth/login", { body: credentials })),
    onSuccess: (user) => queryClient.setQueryData(ME, user),
  });
}

export function useLogout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      await api.POST("/auth/logout");
    },
    onSuccess: () => {
      queryClient.clear();
      queryClient.setQueryData(ME, null);
    },
  });
}

// Orders are for Admin and Manager, as the API's OrdersPolicy says; the menu shows only what the role may open.
export const canUseOrders = (user: CurrentUser) => user.role === "Admin" || user.role === "Manager";
