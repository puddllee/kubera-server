defmodule Kubera.Guardian do
  use Guardian, otp_app: :kubera

  alias Kubera.Accounts
  alias Kubera.Accounts.User

  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :reason_for_error}

  def resource_from_claims(claims) do
    case Accounts.get_user(claims["sub"]) do
      %User{} = user -> {:ok, user}
      _ -> {:error, "Resource not found"}
    end
  end

end
