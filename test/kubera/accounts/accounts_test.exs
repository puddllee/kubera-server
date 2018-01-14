defmodule Kubera.AccountsTest do
  use Kubera.DataCase

  alias Kubera.Accounts

  @valid_user_attrs %{auth_provider: "some auth_provider", avatar: "some avatar", first_name: "some first_name", last_name: "some last_name", name: "some name", email: "some@email.com"}
  @update_user_attrs %{auth_provider: "some updated auth_provider", avatar: "some updated avatar", first_name: "some updated first_name", last_name: "some updated last_name", name: "some updated name"}
  @invalid_user_attrs %{auth_provider: nil, avatar: nil, first_name: nil, last_name: nil, name: nil}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Accounts.create_user()

    user
  end

  describe "users" do
    alias Kubera.Accounts.User


    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_user_attrs)
      assert user.auth_provider == "some auth_provider"
      assert user.avatar == "some avatar"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_user_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_user_attrs)
      assert %User{} = user
      assert user.auth_provider == "some updated auth_provider"
      assert user.avatar == "some updated avatar"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_user_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "groups" do
    alias Kubera.Accounts.Group

    @valid_attrs %{buyin: 42, joinable: true, name: "some name"}
    @update_attrs %{buyin: 43, joinable: false, name: "some updated name"}
    @invalid_attrs %{buyin: nil, joinable: nil, name: nil}

    def group_fixture(user, attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> (fn group -> Accounts.create_group(user, group) end).()

      group
    end

    test "list_groups/1 returns all groups" do
      user = user_fixture()
      group = group_fixture(user)
      groups = Accounts.list_groups(user)
      assert Enum.map(groups, fn g -> g.uid end) == [group.uid]
      assert Enum.count(groups) > 0
    end

    test "get_group/2 returns the group with given id" do
      user = user_fixture()
      group = group_fixture(user)
      {:ok, g} = Accounts.get_group(user, group.uid)
      assert g.uid == group.uid
    end

    test "create_group/1 with valid data creates a group" do
      user = user_fixture()
      assert {:ok, %Group{} = group} = Accounts.create_group(user, @valid_attrs)
      assert group.buyin == 42
      assert group.joinable == true
      assert group.name == "some name"
    end

    # test "create_group/1 with invalid data returns error changeset" do
    #   user = user_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Accounts.create_group(user, @invalid_attrs)
    # end

    test "update_group/2 with valid data updates the group" do
      user = user_fixture()
      group = group_fixture(user)
      assert {:ok, group} = Accounts.update_group(group, @update_attrs)
      assert %Group{} = group
      assert group.buyin == 43
      assert group.joinable == false
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      user = user_fixture()
      group = group_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_group(group, @invalid_attrs)
      {:ok, g} = Accounts.get_group(user, group.uid)
      assert g == Map.put(g, :users, [user])
    end

    test "delete_group/1 deletes the group" do
      user = user_fixture()
      group = group_fixture(user)
      assert {:ok, %Group{}} = Accounts.delete_group(group)
      {:error, nil} = Accounts.get_group(user, group.uid)
    end

    test "change_group/1 returns a group changeset" do
      user = user_fixture()
      group = group_fixture(user)
      assert %Ecto.Changeset{} = Accounts.change_group(group)
    end
  end
end
