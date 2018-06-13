defmodule SMSRestWeb.Router do
  use SMSRestWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SMSRestWeb do
    pipe_through(:api)
    post("/numbers/:phoneNumber/outbound", MessageController, :sendMessage)
    post("/users/:userId/outbound", MessageController, :sendMessage)
    post("/*path", MessageController, :return404)
    # match _, MessageController, :return404
  end
end
