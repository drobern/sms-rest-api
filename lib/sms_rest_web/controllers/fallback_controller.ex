defmodule SMSRestWeb.FallbackController do
  use Phoenix.Controller
  alias SMSRestWeb.ErrorView

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> render(:"403")
  end
end
