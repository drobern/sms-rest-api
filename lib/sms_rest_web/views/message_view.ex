defmodule SMSRestWeb.MessageView do
  use SMSRestWeb, :view
  alias SMSRestWeb.ResponseError
  alias SMSRestWeb.Success

  def render("message.json", %{response: params}) do
    %SMSRestWeb.Response{
      principalId: params.principalId,
      accountId: params.accountId,
      from: params.from,
      to: params.to,
      content: params.content,
      context: params.context,
      createdOn: params.createdOn
    }
  end

  def render("422.json", %{response: %ResponseError{} = error}) do
    error
  end

  def render("429.json", %{response: %ResponseError{} = error}) do
    error
  end

  def render("500.json", %{response: %ResponseError{} = error}) do
    error
  end

  def render("503.json", %{response: %ResponseError{} = error}) do
    error
  end
end
