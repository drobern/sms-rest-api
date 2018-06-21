defmodule SMSRest.SMSCore do
  alias SMSRestWeb.RequestParams
  alias SmsRouting.Message

  def is_phonenumber_provisioned(
        %RequestParams{
          phoneNumber: phoneNumber,
          accountId: accountId,
          principalId: principalId
        } = requestParams
      ) do
    case SmsCloudlinkDbMock.get_phone_numbers(accountId, principalId) do
      {:ok, [number | _tail]} ->
        {:ok, %{requestParams | from: phoneNumber}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def is_user_provisioned(
        %RequestParams{
          from: nil,
          accountId: accountId,
          principalId: principalId
        } = requestParams
      ) do
    case SmsCloudlinkDbMock.get_phone_numbers(accountId, principalId) do
      {:ok, [number | []]} ->
        # IO.inspect number
        {:ok, %{requestParams | from: number}}

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

  def send_message(%RequestParams{} = params) do
    message = %Message{
      id: Ecto.UUID.generate(),
      to: params.to,
      from: params.from,
      body: params.content,
      options: [],
      metadata: %{accountId: params.accountId, principalId: params.principalId}
    }

    SmsRoutingMock.send_async(message)
  end
end
