defmodule KuberaWeb.UserView do
  use KuberaWeb, :view
  alias KuberaWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    groups = case user.groups do
               %Ecto.Association.NotLoaded{} -> []
               groups -> render_many(groups, KuberaWeb.GroupView, "group.json")
             end
    %{id: user.id,
      name: user.name,
      auth_provider: user.auth_provider,
      first_name: user.first_name,
      last_name: user.last_name,
      avatar: user.avatar,
      groups: groups}
  end
end
