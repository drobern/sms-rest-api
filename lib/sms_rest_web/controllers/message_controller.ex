defmodule SMSRestWeb.MessageController do
  use SMSRestWeb, :controller
  require Logger
  alias SMSRestWeb.RequestParams
  alias SMSRest.SMSCore

  action_fallback(SMSRestWeb.FallbackController)
  plug(:validate_input when action in [:sendMessage])

  def sendMessage(conn, %{"phoneNumber" => number} = params) do
    requestParams = RequestParams.convert_to_struct(params)
    # IO.inspect(requestParams)

    case SMSCore.is_phonenumber_provisioned(requestParams) do
      {:ok, finalParams} ->
        handle_send_message(conn, finalParams)

      {:error, :not_found} ->
        Logger.warn("phonenumber #{number} is not provisioned")

        conn
        |> put_status(:unprocessable_entity)
        |> render(
          "422.json",
          make_error_respone("NumberUnprovisioned", "Number #{number} is not provisioned")
        )
        |> halt()
    end
  end

  def sendMessage(conn, %{"userId" => userId} = params) do
    requestParams = RequestParams.convert_to_struct(params)
    # IO.inspect(requestParams)

    case SMSCore.is_user_provisioned(requestParams) do
      {:ok, finalParams} ->
        handle_send_message(conn, finalParams)

      {:error, :not_found} ->
        Logger.warn("user #{userId} does not have any number")

        conn
        |> put_status(:unprocessable_entity)
        |> render(
          "422.json",
          make_error_respone("UserUnprovisioned", "User #{userId} is not provisioned")
        )
        |> halt()

      {:error, :multiple_numbers} ->
        Logger.warn("user #{userId} has more than one number")

        conn
        |> put_status(:unprocessable_entity)
        |> render("422.json", make_error_respone("MultipleNumbers", "Specify from field"))
        |> halt()
    end
  end

  defp validate_input(conn, _params) do
    changeset = RequestParams.changeset(conn.params)

    if changeset.valid? do
      conn
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render("422.json", %{response: RequestParams.error_messages(changeset)})
      |> halt()
    end
  end

  defp handle_send_message(conn, finalParams) do
    case SMSCore.send_message(finalParams) do
      :ok ->
        conn
        |> put_status(201)
        |> render("message.json", %{
          response: Map.put(finalParams, :createdOn, DateTime.to_string(DateTime.utc_now()))
        })

      {:error, reason} ->
        {status, renderJson, renderParams} =
          case reason do
            :unavailable ->
              Logger.warn("from: #{finalParams.from} Service unavailable")
              {500, "500.json", make_error_respone("ServerError")}

            :full ->
              Logger.warn("from: #{finalParams.from} Server is busy")
              {429, "429.json", make_error_respone("TooManyReqeusts")}

            :noroute ->
              Logger.warn("from: #{finalParams.from} no route for number")
              {500, "500.json", make_error_respone("NoRoute")}
          end

        conn
        |> put_status(status)
        |> render(renderJson, renderParams)
        |> halt()
    end
  end

  defp make_error_respone(name, message \\ "") do
    error = %SMSRestWeb.ResponseError{name: name, message: message}
    %{response: error}
  end
end
