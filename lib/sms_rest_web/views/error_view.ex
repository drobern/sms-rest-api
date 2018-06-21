defmodule SMSRestWeb.ErrorView do
  use SMSRestWeb, :view
  alias SMSRestWeb.ResponseError

  def render("500.json", _assigns) do
    %ResponseError{name: "ServerError", message: ""}
  end

  def render("404.json", _assigns) do
    %ResponseError{name: "InvalidUrl", message: "path does not exist"}
  end
end
