defmodule KuberaWeb.Plugs.UserPlug do

  import Plug.Conn

  @doc """
  Assign `user` and `user_id` to conn for convenince
  """
  def load_user(conn, _) do
    user = conn |> Guardian.Plug.current_resource
    conn
    |> assign(:user, user)
    |> assign(:user_id, user.id)
  end
end
