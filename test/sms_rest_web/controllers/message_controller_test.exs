defmodule SMSRestWeb.MessageControllerTest do
    use SMSRestWeb.ConnCase, async: true

    test "POST outbound invalid phonenumber", %{conn: conn} do
      conn = post conn, "/numbers/0012345667/outbound", %{from: "21312321", to: "23214", content: "testing sms rest"}
      json_response(conn, 422)    
    end

    test "POST numbers/:phoneNumber/outbound invalid from", %{conn: conn} do
      conn = post conn, "/numbers/12345667/outbound", %{from: "0021312321", to: "23214", content: "testing sms rest"}
      json_response(conn, 422)  
    end

    test "POST numbers/:phoneNumber/outbound invalid to", %{conn: conn} do
      conn = post conn, "/numbers/12345667/outbound", %{from: "21312321", to: "0023214", content: "testing sms rest"}
      json_response(conn, 422)  
    end

    test "POST users/:userId/outbound invalid to", %{conn: conn} do
      conn = post conn, "/users/me/outbound", %{from: "0021312321", to: "23214", content: "testing sms rest"}
      json_response(conn, 422)  
    end

    test "POST users/:userId/outbound Missing content", %{conn: conn} do
      conn = post conn, "/users/me/outbound", %{from: "21312321", to: "23214"}
      json_response(conn, 422)  
    end
    
  end