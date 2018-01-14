defmodule KuberaWeb.GroupControllerTest do
  use KuberaWeb.ConnCase

  alias Kubera.Accounts
  alias Kubera.Accounts.Group

  @create_attrs %{"buyin" => 42, "joinable" => true, "name" => "some name"}
  @update_attrs %{"buyin" => 43, "name" => "some updated name"}
  @invalid_attrs %{buyin: nil, joinable: nil, name: nil}

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("shit", "shit")
    {:ok, conn: conn}
  end

  describe "index" do
    setup [:login, :create_group]

    test "lists all groups", %{conn: conn, group: %{id: id, uid: uid}} do
      conn = get conn, group_path(conn, :index)
      assert json_response(conn, 200) == [Map.merge(@create_attrs, %{
                                                 "id" => id,
                                                 "uid" => uid,
                                                 "users" => []
                                                    })]
    end
  end

  describe "create group" do
    setup [:login]

    test "renders group when data is valid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @create_attrs
      assert %{"uid" => uid} = json_response(conn, 201)

      user = conn.assigns.user
      {:ok, group} = Accounts.get_group(user, uid)
      assert Map.get(group, :uid) == uid
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update group" do
    setup [:login, :create_group]

    test "renders group when data is valid", %{conn: conn, group: %Group{uid: uid}} do
      conn = put conn, group_path(conn, :update, uid), group: @update_attrs
      assert %{"uid" => ^uid} = json_response(conn, 200)

      user = conn.assigns.user
      {:ok, group} = Accounts.get_group(user, uid)
      assert Map.get(group, :name) == "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, group: %Group{uid: uid}} do
      conn = put conn, group_path(conn, :update, uid), group: @invalid_attrs
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete group" do
    setup [:login, :create_group]

    test "deletes chosen group", %{conn: conn, group: %Group{uid: uid}} do
      conn = delete conn, group_path(conn, :delete, uid)
      assert response(conn, 204)
      user = conn.assigns.user

      {:error, nil} = Accounts.get_group(user, uid)
    end
  end

  defp create_group(%{conn: conn}) do
    {:ok, group} = Accounts.create_group(conn.assigns.user, @create_attrs)
    {:ok, group: group}
  end

  defp login(%{conn: conn}) do
    {:ok, conn: conn |> login_user()}
  end
end
