defmodule SMSRestWeb.RequestParams do
  defstruct principalId: nil,
            accountId: nil,
            from: nil,
            to: nil,
            content: nil,
            context: nil,
            phoneNumber: nil,
            userId: nil

  import Ecto.Changeset
  alias SMSRestWeb.ResponseError

  @e164_regex ~r/^[1-9]\d{1,14}$/
  # TODO: can be changed once finalized
  @max_content 1000

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

  def convert_to_struct(params) do
    params_with_atom_keys =
      for {key, val} <- params, into: %{} do
        {String.to_existing_atom(key), val}
      end
    struct(%SMSRestWeb.RequestParams{}, params_with_atom_keys)
  end

  # TODO: validate principalId and content
  def changeset(%{"phoneNumber" => _number} = params) do
    data = %{}
    {data, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:to, :content], message: "required")
    |> validate_format(:phoneNumber, @e164_regex)
    |> validate_format(:from, @e164_regex)
    |> validate_format(:to, @e164_regex)
    |> validate_length(:content, max: @max_content, count: :codepoints, message: "contentTooLarge")
  end

  def changeset(%{"userId" => _userId} = params) do
    data = %{}
    {data, types}
    |> cast(params, Map.keys(types))
    |> validate_required([:to, :content], message: "required")
    |> validate_format(:from, @e164_regex)
    |> validate_format(:to, @e164_regex)
    |> validate_length(:content, max: @max_content, count: :codepoints, message: "contentTooLarge")
  end

  def find_missing_params_or_large_content({key, {"required", _}}, {_, isContentLarge, missingFields}) do
    {true, isContentLarge, "#{missingFields}, #{key}"}
  end

  def find_missing_params_or_large_content({key, {"contentTooLarge", _}}, {isMissing, _, missingFields}) do
    {isMissing, true, "#{missingFields}, #{key}"}
  end

  def find_missing_params_or_large_content({key, value}, acc) do
    acc
  end

  def error_messages(changeset) do
    # IO.inspect changeset
    {isMissing, isContentLarge, missingFieldswithComma} =
      Enum.reduce(changeset.errors, {false, false, ""}, &find_missing_params_or_large_content/2)
    if isMissing do
      ", " <> missingFields = missingFieldswithComma
      # TODO: missingFields can be added if required in response
      {422, %ResponseError{
        name: "MissingParams",
        message: "one or more required parameters are missing or empty"
      }}
    end
    if isContentLarge do
      {413, %ResponseError{
        name: "ContentTooLarge",
        message: "content length is larger than allowed limit"
      }}
    else
      ", " <> invalidParams =
        Enum.reduce(changeset.errors, "", fn {key, value}, acc ->
          "#{acc}, #{key}"
        end)
      # TODO: invalid fields can be added if required in response
      {422, %ResponseError{name: "InvalidParams", message: "one or more parameters are invalid"}}
    end

    # Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    #   Enum.reduce(opts, msg, fn {key, value}, acc ->
    #     IO.write("#{key} and #{msg}")
    #     IO.write(IO.inspect acc)
    #     String.replace(acc, "%{#{key}}", to_string(value))
    #   end)
    # end)
  end
end
