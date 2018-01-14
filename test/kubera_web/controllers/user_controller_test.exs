defmodule KuberaWeb.UserControllerTest do
  use KuberaWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "show profile" do
    test "show user profile", %{conn: conn} do
      conn = get login_user(conn), user_path(conn, :show)
      user = json_response(conn, 200)

      assert Map.delete(user, "id") ==  %{
        "auth_provider" => "google",
        "avatar" => "avatar",
        "first_name" => "First",
        "last_name" => "Last",
        "name" => "First Last",
        "groups" => []}
    end

    test "unauthorized error when user is not logged in", %{conn: conn} do
      conn = get conn, user_path(conn, :show)
      assert response(conn, 401)
    end
  end
end
