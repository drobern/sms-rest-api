defmodule SMSRestWeb.Response do
  defstruct principalId: nil,
            accountId: nil,
            from: nil,
            to: nil,
            content: nil,
            context: nil,
            createdOn: nil
end
