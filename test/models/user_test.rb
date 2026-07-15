require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end


  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should not be valid without name" do
    @user.name = nil
    assert_not @user.valid?
  end

  test "should not be valid without email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should not be valid with invalid email format" do
    @user.email = "invalid-email"
    assert_not @user.valid?
  end

  test "should not be valid with duplicate email" do
    duplicate = @user.dup
    assert_not duplicate.valid?
  end

  test "should not be valid with short password" do
    @user.password = "12345"
    @user.password_confirmation = "12345"
    assert_not @user.valid?
  end

  test "should authenticate with correct password" do
    assert @user.authenticate("password123")
  end

  test "should not authenticate with wrong password" do
    assert_not @user.authenticate("wrongpassword")
  end

  test "should have many favorites" do
    assert @user.favorites.is_a?(ActiveRecord::Associations::CollectionProxy)
    assert_kind_of Favorite, @user.favorites.build
  end

  test "should destroy associated favorites when destroyed" do
    favorite_count = @user.favorites.count
    assert_difference("Favorite.count", -favorite_count) do
      @user.destroy
    end
  end

  test "should create a new user with valid data" do
    new_user = User.new(
      name: "New",
      email: "new@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert new_user.save
  end

  test "password_digest should be present after save" do
    new_user = User.new(
      name: "Test User",
      email: "testuser@example.com",
      password: "securepass123",
      password_confirmation: "securepass123"
    )
    new_user.save
    assert_not_nil new_user.password_digest
  end
end
