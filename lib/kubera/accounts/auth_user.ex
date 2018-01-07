defmodule AuthUser do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Ueberauth.Auth

  def find_or_create(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  def basic_info(auth) do
    %{
      avatar: auth.info.image,
      email: auth.info.email,
      name: auth.info.name,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name
    }
  end
end
