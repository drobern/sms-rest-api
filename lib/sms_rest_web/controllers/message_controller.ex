defmodule SMSRestWeb.MessageController do
  use SMSRestWeb, :controller
  alias SMSRestWeb.RequestValidation
  alias SMSRest.SMSCore

  action_fallback(SMSRestWeb.FallbackController)
  plug(:validate_input when action in [:sendMessage])

  def sendMessage(conn, %{"phoneNumber" => number} = params) do
    case SMSCore.is_phonenumber_provisioned(params) do
    {:ok, number} ->
      conn
      |> put_status(:created)
      |> render("message.json", %{data: number})
    {:error, :not_found} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("422.json", %{name: "NumberUnprovisioned", message: "Number #{number} is not provisioned"})
      |> halt()
    end
  end

  def sendMessage(conn, %{"userId" => userId} = params) do
    case SMSCore.is_user_provisioned(params) do
    {:ok, number} ->
      conn
      |> put_status(:created)
      |> render("message.json", %{data: number})
    {:error, :not_found} ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("422.json", %{name: "UserUnprovisioned", message: "User #{userId} is not provisioned"})
      |> halt()
    {:error, :multiple_numbers} -> 
      conn
      |> put_status(:unprocessable_entity)
      |> render("422.json", %{name: "MultipleNumbers", message: "Specify from field"})
      |> halt()
    end
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
