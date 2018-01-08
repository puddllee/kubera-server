defmodule KuberaWeb.GroupView do
  use KuberaWeb, :view
  alias KuberaWeb.GroupView

  def render("index.json", %{groups: groups}) do
    render_many(groups, GroupView, "group.json")
  end

  def render("show.json", %{group: group}) do
    render_one(group, GroupView, "group.json")
  end

  def render("group.json", %{group: group}) do
    users = case group.users do
              %Ecto.Association.NotLoaded{} -> []
              users -> render_many(users, KuberaWeb.UserView, "user.json")
            end
    %{id: group.id,
      name: group.name,
      uid: group.uid,
      buyin: group.buyin,
      joinable: group.joinable,
      users: users}
  end
end
