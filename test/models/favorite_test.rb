require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @favorite = favorites(:one)
  end

  test "should be valid with valid attributes" do
    assert @favorite.valid?
  end

  test "should not be valid without game_id" do
    @favorite.game_id = nil
    assert_not @favorite.valid?
  end

  test "should not allow duplicate game_id for the same user" do
    duplicate = @user.favorites.new(game_id: @favorite.game_id)
    assert_not duplicate.valid?
  end

  test "should belong to a user" do
    assert @favorite.user.present?
    assert_equal @user, @favorite.user
  end

  test "should create a favorite for a user" do
    new_favorite = @user.favorites.new(game_id: 9999)
    assert new_favorite.save
  end

  test "should destroy favorite" do
    assert_difference("Favorite.count", -1) do
      @favorite.destroy
    end
  end

  test "user should have many favorites" do
    assert @user.favorites.any?
    assert_kind_of Favorite, @user.favorites.first
  end

  test "should not create favorite with same game_id for same user" do
    assert_no_difference("Favorite.count") do
      duplicate = @user.favorites.create(game_id: @favorite.game_id)
      assert_not duplicate.persisted?
    end
  end

  test "should be valid without category" do
    @favorite.category = nil
    assert @favorite.valid?
  end

  test "should allow assigning a category" do
    @favorite.category = categories(:one)
    assert @favorite.valid?
  end
end
