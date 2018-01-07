defmodule KuberaWeb.Plugs.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :kubera

  import Plug.Conn

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
  plug :load_user

  @doc """
  Assign `user` and `user_id` to conn for convenience
  """
  def load_user(conn, _) do
    user = conn |> Guardian.Plug.current_resource
    conn
    |> assign(:user, user)
    |> assign(:user_id, user.id)
  end
end
