defmodule KuberaWeb.GroupController do
  use KuberaWeb, :controller

  alias Kubera.Accounts
  alias Kubera.Accounts.Group
  import KuberaWeb.ErrorView

  action_fallback KuberaWeb.FallbackController

  def index(conn, _params) do
    groups = Accounts.list_groups(conn.assigns.user)
    render(conn, "index.json", groups: groups)
  end

  def create(conn, %{"group" => group_params}) do
    case Accounts.create_group(conn.assigns.user, group_params) do
      {:ok, %Group{} = group} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", group_path(conn, :show, group))
        |> render("show.json", group: group)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KuberaWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => uid}) do
    case Accounts.get_group(conn.assigns.user, uid) do
      {:ok, %Group{} = group} ->
        conn
        |> render("show.json", group: group)
      {:error, _} ->
        send_error(conn, 404)
    end
  end

  def update(conn, %{"id" => uid, "group" => group_params}) do
    with  {:ok, %Group{} = group} <- Accounts.get_group(conn.assigns.user, uid),
          {:ok, %Group{} = group} <- Accounts.update_group(group, group_params) do
      render(conn, "show.json", group: group)
    else
      _ -> send_error(conn, 404)
    end
  end

  def delete(conn, %{"id" => uid}) do
    with  {:ok, %Group{} = group} <- Accounts.get_group(conn.assigns.user, uid),
          {:ok, %Group{}} <- Accounts.delete_group(group) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_error(conn, 404)
    end
  end
end
