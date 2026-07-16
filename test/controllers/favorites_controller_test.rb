require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = JsonWebToken.encode({ user_id: @user.id, type: "User" })
    @favorite = favorites(:one)
  end

  test "should get user's favorites" do
    get "/favorites",
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "should not get favorites without authentication" do
    get "/favorites"
    assert_response :unauthorized
  end

  test "should create a new favorite" do
    assert_difference("Favorite.count") do
      post "/favorites",
          params: { game_id: 9999 },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 9999, json["game_id"]
  end

  test "should not create duplicate favorite for same game" do
    assert_no_difference("Favorite.count") do
      post "/favorites",
          params: { game_id: @favorite.game_id },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :unprocessable_entity
  end

  test "should destroy favorite" do
    assert_difference("Favorite.count", -1) do
      delete "/favorites/#{@favorite.game_id}",
            headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :no_content
  end

  test "should not destroy favorite of another user" do
    other_favorite = favorites(:two)

    delete "/favorites/#{other_favorite.id}",
          headers: { Authorization: "Bearer #{@token}" }

    assert_response :not_found
  end

  test "should not destroy without authentication" do
    delete "/favorites/#{@favorite.game_id}"
    assert_response :unauthorized
  end

  test "should not create favorite without game_id" do
    assert_no_difference("Favorite.count") do
      post "/favorites",
          params: {},
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :unprocessable_entity
  end

  test "should update favorite category" do
    category = categories(:one)

    put "/favorites/#{@favorite.game_id}",
        params: { category_id: category.id },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success

    @favorite.reload
    assert_equal category.id, @favorite.category_id

    json = JSON.parse(response.body)
    assert_equal category.id, json["category_id"]
  end

  test "should return not found when updating nonexistent favorite" do
    put "/favorites/999999",
        params: { category_id: categories(:one).id },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :not_found
  end

  test "should return not found when category does not exist" do
    put "/favorites/#{@favorite.game_id}",
        params: { category_id: 999999 },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Category not found", json["error"]
  end

  test "should remove favorite category" do
    category = categories(:one)

    @favorite.update!(category: category)

    put "/favorites/#{@favorite.game_id}",
        params: { category_id: nil },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success

    @favorite.reload
    assert_nil @favorite.category_id
  end

  test "should not update favorite without authentication" do
    put "/favorites/#{@favorite.game_id}",
        params: { category_id: categories(:one).id }

    assert_response :unauthorized
  end

  test "should not update another user's favorite" do
    other_favorite = favorites(:two)

    put "/favorites/#{other_favorite.game_id}",
        params: { category_id: categories(:one).id },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :not_found
  end
end
