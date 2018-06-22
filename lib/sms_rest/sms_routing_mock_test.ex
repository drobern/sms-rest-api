defmodule SmsRoutingMockTest do
  @doc """
    Send asynchronously a SMS message (mock).

    Uses the "to" field in the SMS message to simulate responses.
  """
  @message_types [
    {~r/11$/, :full},
    {~r/22$/, :noroute},
    {~r/33$/, :unavailable},
    {~r/44$/, :throw_node},
    {~r/55$/, :throw_timeout}
  ]

  @spec send_async(msg :: SmsRouting.Message.t(), opts :: keyword()) ::
          :ok | {:error, :full} | {:error, :noroute} | {:error, :unavailable} | no_return
  def send_async(%SmsRouting.Message{} = message, _opts \\ []) do

    {_, type} = Enum.find(@message_types, {nil, :unknown}, fn {reg, type} ->
      String.match?(message.to, reg)
    end)

    case type do
      :full -> {:error, :full}
      :noroute -> {:error, :noroute}
      :unavailable -> {:error, :unavailable}
      :throw_node -> exit(:throw_node)
      :throw_timeout -> exit(:throw_timeout)
      _ -> :ok
    end

  end
end
