require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:one)
    @category = categories(:one)
    @token = JsonWebToken.encode({ user_id: @admin.id, type: "AdminUser" })
  end

  test "should get index of categories" do
    get "/categories",
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "should create category when authenticated as admin" do
    assert_difference("Category.count") do
      post "/categories",
          params: { name: "RPG", description: "Role Playing Games" },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "RPG", json["name"]
  end

  test "should not create category without authentication" do
    post "/categories", params: { name: "Sports" }

    assert_response :unauthorized
  end

  test "should update category" do
    put "/categories/#{@category.id}",
        params: { name: "Updated Adventure", description: "New description" },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated Adventure", json["name"]
  end

  test "should return not found when updating non-existent category" do
    put "/categories/999999",
        params: { name: "Ghost" },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :not_found
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete "/categories/#{@category.id}",
            headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :no_content
  end

  test "should create category with nested category param" do
    assert_difference("Category.count") do
      post "/categories",
          params: {
            category: {
              name: "Strategy",
              description: "Strategy games"
            }
          },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :created
  end

  test "should not create category as regular user" do
    user = users(:one)
    token = JsonWebToken.encode({ user_id: user.id, type: "User" })

    assert_no_difference("Category.count") do
      post "/categories",
          params: { name: "Sports" },
          headers: { Authorization: "Bearer #{token}" }
    end

    assert_response :forbidden

    json = JSON.parse(response.body)
    assert_equal "Forbidden", json["error"]
  end

  test "should not create duplicate category" do
    assert_no_difference("Category.count") do
      post "/categories",
          params: {
            name: @category.name,
            description: "Duplicate"
          },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_not_empty json["errors"]
  end

  test "should not create category without name" do
    assert_no_difference("Category.count") do
      post "/categories",
          params: {
            name: "",
            description: "Invalid"
          },
          headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :unprocessable_entity
  end

  test "should not update category without authentication" do
    put "/categories/#{@category.id}",
        params: { name: "Updated" }

    assert_response :unauthorized
  end

  test "should not update category as regular user" do
    user = users(:one)
    token = JsonWebToken.encode({ user_id: user.id, type: "User" })

    put "/categories/#{@category.id}",
        params: { name: "Updated" },
        headers: { Authorization: "Bearer #{token}" }

    assert_response :forbidden

    json = JSON.parse(response.body)
    assert_equal "Forbidden", json["error"]
  end

  test "should not update category with invalid data" do
    put "/categories/#{@category.id}",
        params: { name: "" },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_not_empty json["errors"]
  end

  test "should update category with nested params" do
    put "/categories/#{@category.id}",
        params: {
          category: {
            name: "Nested Update",
            description: "Updated description"
          }
        },
        headers: { Authorization: "Bearer #{@token}" }

    assert_response :success

    @category.reload
    assert_equal "Nested Update", @category.name
    assert_equal "Updated description", @category.description
  end

  test "should not destroy category without authentication" do
    assert_no_difference("Category.count") do
      delete "/categories/#{@category.id}"
    end

    assert_response :unauthorized
  end

  test "should not destroy category as regular user" do
    user = users(:one)
    token = JsonWebToken.encode({ user_id: user.id, type: "User" })

    assert_no_difference("Category.count") do
      delete "/categories/#{@category.id}",
            headers: { Authorization: "Bearer #{token}" }
    end

    assert_response :forbidden

    json = JSON.parse(response.body)
    assert_equal "Forbidden", json["error"]
  end

  test "should return not found when destroying nonexistent category" do
    assert_no_difference("Category.count") do
      delete "/categories/999999",
            headers: { Authorization: "Bearer #{@token}" }
    end

    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "Category not found", json["error"]
  end
end
