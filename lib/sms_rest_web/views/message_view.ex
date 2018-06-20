defmodule SMSRestWeb.MessageView do
    use SMSRestWeb, :view
    alias SMSRest.Error

    def render("message.json", %{data: number}) do
        %{number: number}
    end

    def render("422.json", %{error: error}) do
        IO.inspect error
        error
    end

    def render("422.json", %{name: name, message: message}) do
        # IO.inspect error
        %Error{name: name, message: message}
    end

    def render("404.json", %{error: error}) do
        %{error: error}
    end

    
end