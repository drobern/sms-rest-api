defmodule SMSRestWeb.MessageView do
    use SMSRestWeb, :view

    def render("message.json", %{data: number}) do
        %{number: number}
    end

    def render("422.json", %{error: error}) do
        %{error: error}
    end

    def render("404.json", %{error: error}) do
        %{error: error}
    end
end