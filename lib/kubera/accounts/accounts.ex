defmodule Kubera.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Kubera.Repo

  alias Kubera.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)
  def load_groups(user), do: user |> Repo.preload(:groups)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Kubera.Accounts.Group

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups(user) do
    Ecto.assoc(user, :groups)
    |> Repo.all()
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group(%User{} = user, uid) do
    group = Ecto.assoc(user, :groups)
    |> where(uid: ^uid)
    |> preload(:users)
    |> Repo.one()

    case group do
      %Group{} = group ->
        {:ok, group}
      _ ->
        {:error, nil}
    end
  end


  def get_joinable_group(uid) do
    case Repo.get_by(Group, uid: uid, joinable: true) do
      %Group{} = group -> {:ok, group}
      nil -> {:error, nil}
    end
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(%User{} = user, attrs \\ %{}) do
    uid = Hashids.new([min_len: 3])
    |> Hashids.encode(:rand.uniform(10000000))

    key = case Map.get(attrs, :name) do
            nil -> "uid"
            _   -> :uid
          end

    pgroup = %Group{}
    |> Group.changeset(Map.put(attrs, key, uid))
    |> Repo.insert()

     case pgroup do
       {:ok, group} -> add_user_to_group(user, group)
       {:error, changeset} -> {:error, changeset}
     end
  end

  def add_user_to_group(%User{} = user, %Group{} = group) do
    user = Repo.preload(user, :groups)
    group = Repo.preload(group, :users)

    groups = user.groups ++ [group]
    |> Enum.map(&Ecto.Changeset.change/1)

    puser = user
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:groups, groups)
    |> Repo.update()

    case puser do
      {:ok, %User{}} -> {:ok, group |> Repo.preload(:users)}
      _ -> {:error, nil}
    end
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{source: %Group{}}

  """
  def change_group(%Group{} = group) do
    Group.changeset(group, %{})
  end
end
