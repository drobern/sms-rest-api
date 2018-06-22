defmodule SmsCloudlinkDbMockTest do
  @doc """
  Get a list of SMS enabled phone numbers for cloudlink account_id and principal_id (test mock).
  Based on the principalId and numbers pattern returns deterministic values.
  """
  @principalId_types [
    {~r/single_number/, :single},
    {~r/multi_numbers/, :multi},
    {~r/not_found/, :not_found},
    {~r/throw_node/, :throw_node},
    {~r/time_out/, :throw_timeout}
  ]

  @numbers %{single: ["+1234567890"], multi: ["+1234567890", "+2345678910"] }

  @spec get_phone_numbers(
          account_id :: string,
          principal_id :: string
        ) :: {:ok, phone_numbers :: list(string)} | {:error, :not_found} | no_return
  def get_phone_numbers(account_id, principal_id)
      when is_binary(account_id) and is_binary(principal_id) do

   {_, type} = Enum.find(@principalId_types, {nil, :unknown}, fn {reg, type} ->
    String.match?(principal_id, reg)
  end)
    case type do
      :single -> {:ok, @numbers[:single]}
      :multi -> {:ok, @numbers[:multi]}
      :not_found -> {:error, :not_found}
      :throw_node -> exit(:throw_node)
      :throw_timeout -> exit(:throw_timeout)
      _ -> exit(:throw_something)
    end
  end
end
