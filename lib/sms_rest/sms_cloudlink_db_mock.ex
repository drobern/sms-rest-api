defmodule SmsCloudlinkDbMock do

  use Agent

  @doc """
  Get a list of SMS enabled phone numbers for cloudlink account_id and principal_id (mock).
  Should be successful most of the time with some fairly common errors thrown in occasionally.
  In order to run this code you need the `:faker` and `:ex_phone_number` dependency. Go to
  https://hex.pm to find them and then add them to `mix.exs`.
  """


  @spec get_phone_numbers(
          account_id :: string,
          principal_id :: string
        ) :: {:ok, phone_numbers :: list(string)} | {:error, :not_found} | no_return
  def get_phone_numbers(account_id, principal_id)
      when is_binary(account_id) and is_binary(principal_id) do

    # Todo: check if this is the right way of doing.
    rec = nil
    if Application.get_env(:sms_rest, :environment) == :test do
      dbrecords = Agent.get(__MODULE__, fn set -> set end)
      IO.puts("#####test code")
      rec = find_record(dbrecords, account_id, principal_id)
    end

    case rec do
      nil ->
        selected_response =
          (for(
             _ <- 1..10,
             do: {
               :ok,
               [
                 Faker.Phone.EnUs.phone()
                 |> ExPhoneNumber.parse("US")
                 |> elem(1)
                 |> ExPhoneNumber.format(:e164)
               ]
             }
           ) ++
             [
               {
                 :ok,
                 [
                   Faker.Phone.EnUs.phone()
                   |> ExPhoneNumber.parse("US")
                   |> elem(1)
                   |> ExPhoneNumber.format(:e164),
                   Faker.Phone.EnUs.phone()
                   |> ExPhoneNumber.parse("US")
                   |> elem(1)
                   |> ExPhoneNumber.format(:e164),
                   Faker.Phone.EnUs.phone()
                   |> ExPhoneNumber.parse("US")
                   |> elem(1)
                   |> ExPhoneNumber.format(:e164)
                 ]
                 |> Enum.take(Enum.random(2..3))
               },
               {:error, :not_found},
               :throw_timeout,
               :throw_node,
               :throw_other
             ])
          |> Enum.take_random(1)
          |> hd()

        case selected_response do
          :throw_node -> exit({:nodedown, :fakenode@fakehost})
          :throw_timeout -> exit(:timeout)
          :throw_other -> exit(:something)
          other -> other
        end
      _ ->
        {:ok, rec.phone_numbers}
    end
  end

  @spec get_account_id_and_principal_id(phone_number :: string) ::
          {:ok, account_id :: string, principal_id :: string} | {:error, :not_found} | no_return
  def get_account_id_and_principal_id(phone_number) do
    r1 = :crypto.strong_rand_bytes(10) |> Base.encode16() |> String.downcase()
    r2 = :crypto.strong_rand_bytes(10) |> Base.encode16() |> String.downcase()

    selected_response =
      (for(
         _ <- 1..10,
         do: {
           :ok,
           "account_#{r1}",
           "principal_#{r2}"
         }
       ) ++ [{:error, :not_found}, :throw_timeout, :throw_node, :throw_other])
      |> Enum.take_random(1)
      |> hd()

    case selected_response do
      :throw_node -> exit({:nodedown, :fakenode@fakehost})
      :throw_timeout -> exit(:timeout)
      :throw_other -> exit(:something)
      other -> other
    end
  end

  # Intializes the module with Mock DB records
  # eg: [
  #     %{accountId: "1000", phone_numbers: ["123456", "234456"], principalId: "test1@mitel.com"},
  #     %{accountId: "1000", phone_numbers: ["234456"], principalId: "test2@mitel.com"}
  #     ]
  def initdb(dbrecords \\ %{}) do
    Agent.start_link(fn -> dbrecords end, name: __MODULE__)
  end

  defp find_record(collection, accountId, principalId) do
    Enum.find(collection, fn element ->
      element.accountId == accountId and element.principalId == principalId
    end)
  end

  defp find_record(collection, phone_number) do
    Enum.find(collection, fn element ->
      Enum.find(element.phone_numbers, fn num ->
        phone_number == num
      end)
    end)
  end
end
