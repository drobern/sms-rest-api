defmodule SmsRoutingMock do
  @doc """
    Send asynchronously a SMS message (mock).

    Should return `:ok` most of the time by may throw and return various errors defined below.
  """
  @spec send_async(msg :: SmsRouting.Message.t(), opts :: keyword()) ::
          :ok | {:error, :full} | {:error, :noroute} | {:error, :unavailable} | no_return
  def send_async(%SmsRouting.Message{}, _opts \\ []) do
    case Enum.take_random((for _ <- 1..10, do: :ok) ++ [
      {:error, :full},
      {:error, :noroute},
      {:error, :unavailable},
      :throw_node,
      :throw_timeout,
      :throw_other
    ],
           1
         ) |> hd() do
      :throw_node    -> exit({:nodedown, :fakenode@fakehost})
      :throw_timeout -> exit(:timeout)
      :throw_other   -> exit(:something)
      other          -> other
    end
  end
end
