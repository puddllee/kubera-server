defmodule KuberaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Kubera.Accounts
  alias Kubera.Accounts.User

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import KuberaWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint KuberaWeb.Endpoint

      # Sign in the user and place the `jwt` token in header
      def guardian_login(%User{} = user), do: guardian_login(conn(), user, :token, [])
      def guardian_login(%User{} = user, token), do: guardian_login(conn(), user, token, [])
      def guardian_login(%User{} = user, token, opts), do: guardian_login(conn(), user, token, opts)

      def guardian_login(%Plug.Conn{} = conn, user), do: guardian_login(conn, user, :token, [])
      def guardian_login(%Plug.Conn{} = conn, user, token), do: guardian_login(conn, user, token, [])
      def guardian_login(%Plug.Conn{} = conn, user, token, opts) do
        conn = conn
        |> Kubera.Guardian.Plug.sign_in(user)
        jwt = Kubera.Guardian.Plug.current_token(conn)

        conn
        |> assign(:user, user)
        |> assign(:user_id, user.id)
        |> put_req_header("authorization", "Bearer #{jwt}")
        |> Kubera.Guardian.Plug.put_current_resource(user)
      end

      defp login_user(%Plug.Conn{} = conn) do
        {:ok, user} = Accounts.create_user(%{
          auth_provider: "google",
          email: "test@email.com",
          avatar: "avatar",
          first_name: "First",
          last_name: "Last",
          name: "First Last"
        })
        conn |> guardian_login(user)
      end
   end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Kubera.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Kubera.Repo, {:shared, self()})
    end
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

end
