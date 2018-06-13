defmodule SMSRest.Message do
  # defstruct [:principalId, :accountId, :from, :to, :content, :context]
  import Ecto.Changeset

  @e164_regex ~r/^\+?[1-9]\d{1,14}$/

  defp types do
    %{
      principalId: :string,
      accountId: :string,
      from: :string,
      to: :string,
      content: :string,
      context: :string,
      phoneNumber: :string,
      userId: :string
    }
  end

  # TODO: validate principalId and content
  def changeset(%{"phoneNumber" => _number} = params) do
    data = %{}

    {data, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:from, :to])
    |> validate_format(:phoneNumber, @e164_regex)
    |> validate_format(:from, @e164_regex)
    |> validate_format(:to, @e164_regex)
  end

  def changeset(%{"userId" => _userId} = params) do
    data = %{}

    {data, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:from, :to])
    |> validate_format(:from, @e164_regex)
    |> validate_format(:to, @e164_regex)
  end

  def error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
