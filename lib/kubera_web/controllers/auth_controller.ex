defmodule KuberaWeb.AuthController do
  use KuberaWeb, :controller

  alias Kubera.Accounts
  alias Kubera.Accounts.User
  alias Kubera.Repo

  alias Ueberauth.Strategy.Helpers
  import KuberaWeb.ErrorView

  plug Ueberauth

  def request(_conn, _params) do
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    send_error(conn, 401)
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case AuthUser.find_or_create(auth) do
      {:ok, user} ->
        sign_in_user(conn, %{"user" => user})
      {:error, reason} ->
        IO.inspect reason
        send_error(conn, 401)
    end
  end

  def sign_in_user(conn, %{"user" => user}) do
    # Attemp to retrieve exactly one user from the DB,
    # whose email matches the one provided with the login request
    IO.inspect user
    case Repo.get_by(User, email: user.email) do
      %User{} = user ->
        {:ok, jwt, _} = Kubera.Guardian.encode_and_sign(user)

        auth_conn = Kubera.Guardian.Plug.sign_in(conn, user)
        auth_conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> json(%{access_token: jwt}) # Return token to client
      nil ->
        sign_up_user(conn, %{"user" => user})
    end
  end

  def sign_up_user(conn, %{"user" => user}) do
    changeset = User.changeset %User{}, %{
      email: user.email,
      avatar: user.avatar,
      name: user.name,
      first_name: user.first_name,
      last_name: user.last_name,
      auth_provider: "google"
    }

    case Repo.insert changeset do
      {:ok, user} ->
        {:ok, jwt, _} = Kubera.Guardian.encode_and_sign(user)

        conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> json(%{access_token: jwt})
      {:error, _} ->
        send_error(conn, 422)
    end
  end

  def unauthenticated(conn, _params) do
    send_error(conn, 401)
  end

  def unauthorized(conn, _params) do
    send_error(conn, 403)
  end

  def already_authenticated(conn, _params) do
    send_error(conn, 200)
  end

  def no_resource(conn, _params) do
    send_error(conn, 401)
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> send_error(401)
  end
end
