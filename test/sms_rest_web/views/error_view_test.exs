defmodule SMSRestWeb.ErrorViewTest do
  use SMSRestWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(SMSRestWeb.MessageView, "404.json", %{error: "invalid"}) == %{error: "invalid"}
  end
  
end
