defmodule SMSRest.SMSCore do
  @moduledoc """
  SMS backend for controller.
  """
  @sms_cloudlink_db Application.get_env(:sms_rest, :sms_cloudlink_db)
  @sms_routing Application.get_env(:sms_rest, :sms_routing)
  alias SMSRestWeb.RequestParams
  alias SmsRouting.Message

  @spec is_phonenumber_provisioned(params :: SMSRestWeb.RequestParams.t()) ::
          {:ok, params :: SMSRestWeb.RequestParams.t()} | {:error, :not_found}
  def is_phonenumber_provisioned(
        %RequestParams{
          phoneNumber: phoneNumber,
          accountId: accountId,
          principalId: principalId
        } = requestParams
      ) do
    case @sms_cloudlink_db.get_phone_numbers(accountId, principalId) do
      {:ok, [number | _tail]} ->
        # TODO: Check phoneNumber is present in above list
        {:ok, %{requestParams | from: phoneNumber}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  @spec is_user_provisioned(params :: SMSRestWeb.RequestParams.t()) ::
          {:ok, params :: SMSRestWeb.RequestParams.t()}
          | {:error, :not_found}
          | {:error, :multiple_numbers}
  def is_user_provisioned(
        %RequestParams{
          from: nil,   # when from is not given in request
          accountId: accountId,
          principalId: principalId
        } = requestParams
      ) do
    case @sms_cloudlink_db.get_phone_numbers(accountId, principalId) do
      # Must be only one number
      {:ok, [number | []]} ->
        {:ok, %{requestParams | from: number}}

      # Error if more than one number provisioned for user  
      {:ok, _} ->
        {:error, :multiple_numbers}

      {:error, :not_found} ->
        IO.write("account id #{accountId} is not provisoned for sms")
        {:error, :not_found}
    end
  end

  def is_user_provisioned(
        %RequestParams{
          from: from
        } = requestParams
      ) do
    is_phonenumber_provisioned(%{requestParams | phoneNumber: from})
  end

  @spec send_message(params :: SMSRestWeb.RequestParams.t()) ::
          :ok | {:error, :full} | {:error, :noroute} | {:error, :unavailable} | no_return
  def send_message(%RequestParams{} = params) do
    message = %Message{
      id: Ecto.UUID.generate(),
      to: params.to,
      from: params.from,
      body: params.content,
      options: [],
      metadata: %{accountId: params.accountId, principalId: params.principalId}
    }

    @sms_routing.send_async(message)
  end
end
