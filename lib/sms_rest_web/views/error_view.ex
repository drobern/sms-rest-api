defmodule SMSRestWeb.ErrorView do
  use SMSRestWeb, :view
  alias SMSRestWeb.ResponseError

  def render("500.json", _assigns) do
    %ResponseError{name: "ServerError", message: ""}
  end

  def render("404.json", %{reason: %Phoenix.Router.NoRouteError{}}) do
    %ResponseError{name: "InvalidUrl", message: "path does not exist"}
  end

  def render("400.json", %{reason: %Plug.Parsers.ParseError{}}) do
    %ResponseError{name: "InvalidJSONFormat", message: ""}
  end

  def render("415.json", %{reason: %Plug.Parsers.UnsupportedMediaTypeError{}}) do
    %ResponseError{name: "UnsupportedMediaType", message: ""}
  end
end