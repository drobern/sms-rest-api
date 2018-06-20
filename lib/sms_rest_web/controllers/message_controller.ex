defmodule SMSRestWeb.MessageController do
  use SMSRestWeb, :controller
  alias SMSRestWeb.RequestValidation

  action_fallback(SMSRestWeb.FallbackController)
  plug(:validate_input when action in [:sendMessage])

  def sendMessage(conn, %{"phoneNumber" => number} = params) do
    conn
    |> put_status(:created)
    |> render("message.json", %{data: number})
  end

  def sendMessage(conn, %{"userId" => userId} = params) do
    conn
    |> put_status(:created)
    |> render("message.json", %{data: userId})
  end

  # def return404(conn, params) do
  #   conn
  #   |> put_status(:not_found)
  #   |> render("404.json", %{error: "invalid path"})
  # end

  defp validate_input(conn, _params) do
    changeset = RequestValidation.changeset(conn.params)

    if changeset.valid? do
      conn
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render("422.json", %{error: RequestValidation.error_messages(changeset)})
      |> halt()
    end
  end
end
