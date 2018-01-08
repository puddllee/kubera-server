defmodule KuberaWeb.GroupController do
  use KuberaWeb, :controller

  alias Kubera.Accounts
  alias Kubera.Accounts.Group
  alias KuberaWeb.ErrorView

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
      %Group{} = group ->
        conn
        |> render("show.json", group: group)
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json")
    end
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Accounts.get_group!(id)

    with {:ok, %Group{} = group} <- Accounts.update_group(group, group_params) do
      render(conn, "show.json", group: group)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Accounts.get_group!(id)
    with {:ok, %Group{}} <- Accounts.delete_group(group) do
      send_resp(conn, :no_content, "")
    end
  end
end
