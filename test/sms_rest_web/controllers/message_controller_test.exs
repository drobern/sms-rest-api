defmodule SMSRestWeb.MessageControllerTest do
  use SMSRestWeb.ConnCase, async: true

  @max_content 1000

  # POST /numbers/{phoneNumber}/outbound Tescases

  test "POST /numbers/{phoneNumber}/outbound invalid phonenumber", %{conn: conn} do
    conn =
      post(conn, "/numbers/0012345667/outbound", %{
        from: "21312321",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST /numbers/{phoneNumber}/outbound invalid phonenumber 1 digit", %{conn: conn} do
    conn =
      post(conn, "/numbers/1/outbound", %{
        from: "21312321",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST /numbers/{phoneNumber}/outbound invalid phonenumber ascii alphabets", %{conn: conn} do
    conn =
      post(conn, "/numbers/abcd/outbound", %{
        from: "21312321",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/:phoneNumber/outbound invalid from", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345667/outbound", %{
        from: "0021312321",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/:phoneNumber/outbound invalid from unicode", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345667/outbound", %{
        from: "\uFF081\uFF09\u30003456789",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/:phoneNumber/outbound invalid to", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345667/outbound", %{
        from: "21312321",
        to: "0023214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST users/:phonenumber/outbound Missing content", %{conn: conn} do
    conn =
      post(conn, "/users/21312321/outbound", %{
        accountId: "1000",
        principalId: "test@mitel.com",
        from: "21312321",
        to: "23214"
      })

    body = json_response(conn, 422)

    assert ^body = %{
      "message" => "one or more required parameters are missing or empty",
      "name" => "MissingParams"
    }
  end

  test "POST users/:phonenumber/outbound content same as max_content", %{conn: conn} do
    content = 1..@max_content |> Enum.join("") |> String.slice(0, @max_content)

    conn =
      post(conn, "/users/test2@mitel.com/outbound", %{
        accountId: "1000",
        principalId: "test2_single_number@mitel.com",
        from: "23214",
        to: "1234",
        content: content
      })

    body = json_response(conn, 201)
  end

  test "POST users/:phonenumber/outbound content too large", %{conn: conn} do
    content = 1..@max_content |> Enum.join("") |> String.slice(0, @max_content + 1)

    conn = post(conn, "/users/23214/outbound", %{from: "23214", to: "1234", content: content})
    body = json_response(conn, 413)

    assert ^body = %{
      "message" => "content length is larger than allowed limit",
      "name" => "ContentTooLarge"
    }
  end

  test "POST numbers/:phoneNumber/outbound without context", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 201)

    expected_body = %{
      "principalId" => "test_single_number@mitel.com",
      "accountId" => "1000",
      "from" => "12345",
      "to" => "2341",
      "content" => "test content"
    }

    assert Map.take(body, Map.keys(expected_body)) == expected_body
    assert Map.has_key?(body, "createdOn")
    refute Map.has_key?(body, "context")
  end

  test "POST numbers/:phoneNumber/outbound with context", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 201)

    expected_body = %{
      "principalId" => "test_single_number@mitel.com",
      "accountId" => "1000",
      "from" => "12345",
      "to" => "2341",
      "content" => "test content"
    }

    assert Map.take(body, Map.keys(expected_body)) == expected_body
    assert Map.has_key?(body, "createdOn")
    assert Map.has_key?(body, "context")
  end

  test "POST numbers/:phoneNumber/outbound no number provisioned", %{conn: conn} do
    conn =
      post(conn, "/numbers/12345/outbound", %{
        accountId: "1000",
        principalId: "test_not_found@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 422)

    ^body = %{
      "message" => "Number 12345 is not provisioned",
      "name" => "NumberUnprovisioned"
    }
  end

  # POST /users/{userId}/outbound testcases

  test "POST /users/{userId}/outbound invalid to ascii alphabets", %{conn: conn} do
    conn =
      post(conn, "/users/test@mitel.com/outbound", %{
        from: "21312321",
        to: "abcd",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/{userId}/outbound invalid from", %{conn: conn} do
    conn =
      post(conn, "/users/test@mitel.com/outbound", %{
        from: "0021312321",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/{userId}/outbound invalid from unicode", %{conn: conn} do
    conn =
      post(conn, "/users/test@mitel.com/outbound", %{
        from: "\uFF081\uFF09\u30003456789",
        to: "23214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST numbers/{userId}/outbound invalid to", %{conn: conn} do
    conn =
      post(conn, "/users/test@mitel.com/outbound", %{
        from: "21312321",
        to: "0023214",
        content: "testing sms rest"
      })

    body = json_response(conn, 422)
    assert ^body = %{"message" => "one or more parameters are invalid", "name" => "InvalidParams"}
  end

  test "POST users/:userId/outbound Missing content", %{conn: conn} do
    conn = post(conn, "/users/test@mitel.com/outbound", %{from: "21312321", to: "23214"})
    body = json_response(conn, 422)

    assert ^body = %{
      "message" => "one or more required parameters are missing or empty",
      "name" => "MissingParams"
    }
  end

  test "POST users/:userId/outbound Missing to", %{conn: conn} do
    conn = post(conn, "/users/me/outbound", %{from: "23214", content: "testing sms rest"})
    body = json_response(conn, 422)

    assert ^body = %{
      "message" => "one or more required parameters are missing or empty",
      "name" => "MissingParams"
    }
  end

  test "POST users/:userId/outbound Missing empty content", %{conn: conn} do
    content =
      conn =
      post(conn, "/users/test@mitel.com/outbound", %{
        from: "21312321",
        to: "23214",
        content: ""
      })

    body = json_response(conn, 422)

    assert ^body = %{
      "message" => "one or more required parameters are missing or empty",
      "name" => "MissingParams"
    }
  end

  test "POST users/:userId/outbound content same as max_content", %{conn: conn} do
    content = 1..@max_content |> Enum.join("") |> String.slice(0, @max_content)

    conn =
      post(conn, "/users/me/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "1234",
        content: content
      })

    body = json_response(conn, 201)
  end

  test "POST users/:userId/outbound content too large", %{conn: conn} do
    content = 1..@max_content |> Enum.join("") |> String.slice(0, @max_content + 1)

    conn = post(conn, "/users/me/outbound", %{from: "23214", to: "1234", content: content})
    body = json_response(conn, 413)

    assert ^body = %{
      "message" => "content length is larger than allowed limit",
      "name" => "ContentTooLarge"
    }
  end

  test "POST users/userId/outbound without context", %{conn: conn} do
    conn =
      post(conn, "/users/test_single_number@mitel.com/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 201)

    expected_body = %{
      "principalId" => "test_single_number@mitel.com",
      "accountId" => "1000",
      "from" => "23214",
      "to" => "2341",
      "content" => "test content"
    }

    assert Map.take(body, Map.keys(expected_body)) == expected_body
    assert Map.has_key?(body, "createdOn")
    refute Map.has_key?(body, "context")
  end

  test "POST users/userId/outbound with context", %{conn: conn} do
    conn =
      post(conn, "/users/test_single_number@mitel.com/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 201)

    expected_body = %{
      "principalId" => "test_single_number@mitel.com",
      "accountId" => "1000",
      "from" => "23214",
      "to" => "2341",
      "content" => "test content"
    }

    assert Map.take(body, Map.keys(expected_body)) == expected_body
    assert Map.has_key?(body, "createdOn")
    assert Map.has_key?(body, "context")
  end

  test "POST users/userId/outbound no number provisioned", %{conn: conn} do
    conn =
      post(conn, "/users/test_not_found@mitel.com/outbound", %{
        accountId: "1000",
        principalId: "test_not_found@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 422)

    assert ^body =  %{
             "message" => "User test_not_found@mitel.com is not provisioned",
             "name" => "UserNotProvisioned"
           }
  end

  test "POST users/me/outbound with context", %{conn: conn} do
    conn =
      post(conn, "/users/me/outbound", %{
        accountId: "1000",
        principalId: "test_single_number@mitel.com",
        from: "23214",
        to: "2341",
        content: "test content"
      })

    body = json_response(conn, 201)

    expected_body = %{
      "principalId" => "test_single_number@mitel.com",
      "accountId" => "1000",
      "from" => "23214",
      "to" => "2341",
      "content" => "test content"
    }

    assert Map.take(body, Map.keys(expected_body)) == expected_body
    assert Map.has_key?(body, "createdOn")
    assert Map.has_key?(body, "context")
  end
end
