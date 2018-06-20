defmodule SMSRestWeb.ErrorView do
    use SMSRestWeb, :view
    alias SMSRest.Error

    def render("500.json", _assigns) do
        %Error{name: "ServerError", message: ""}
    end

    def render("404.json", _assigns) do
        %Error{name: "InvalidUrl", message: "path does not exist"}
    end
    
end