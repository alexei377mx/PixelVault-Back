require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @admin = admin_users(:one)
  end

  test "should register a new user" do
    assert_difference("User.count") do
      post "/register", params: {
        name: "New",
        email: "new@test.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["user"].present?
    assert json["token"].present?
  end

  test "should not register user with duplicate email" do
    post "/register", params: {
      name: "Duplicate",
      email: @user.email,
      password: "password123",
      password_confirmation: "password123"
    }

    assert_response :unprocessable_entity
  end

  test "should not register user with short password" do
    post "/register", params: {
      name: "Short Pass",
      email: "short@test.com",
      password: "12345",
      password_confirmation: "12345"
    }

    assert_response :unprocessable_entity
  end

  test "should login user with valid credentials" do
    post "/login", params: {
      email: @user.email,
      password: "password123"
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["user"].present?
    assert json["token"].present?
  end

  test "should not login with wrong password" do
    post "/login", params: {
      email: @user.email,
      password: "wrongpassword"
    }

    assert_response :unauthorized
  end

  test "should register a new admin" do
    assert_difference("AdminUser.count") do
      post "/admin/register", params: {
        name: "New admin",
        email: "adminnew@test.com",
        password: "adminpass123",
        password_confirmation: "adminpass123"
      }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["admin"].present?
    assert json["token"].present?
  end

  test "should login admin with valid credentials" do
    post "/admin/login", params: {
      email: @admin.email,
      password: "password123"
    }

    assert_response :success
    json = JSON.parse(response.body)
    assert json["admin"].present?
    assert json["token"].present?
  end

  test "should not login admin with wrong password" do
    post "/admin/login", params: {
      email: @admin.email,
      password: "wrongpass"
    }

    assert_response :unauthorized
  end

  test "should support auth nested parameter" do
    post "/register", params: {
      auth: {
        name: "Nested User",
        email: "nested@test.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_response :created
  end

  test "should not register admin with duplicate email" do
    assert_no_difference("AdminUser.count") do
      post "/admin/register", params: {
        name: "Duplicate Admin",
        email: @admin.email,
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_not_empty json["errors"]
  end

  test "should not register admin with short password" do
    assert_no_difference("AdminUser.count") do
      post "/admin/register", params: {
        name: "Short Password",
        email: "shortadmin@test.com",
        password: "12345",
        password_confirmation: "12345"
      }
    end

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_not_empty json["errors"]
  end

  test "should not login user with nonexistent email" do
    post "/login", params: {
      email: "missing@example.com",
      password: "password123"
    }

    assert_response :unauthorized

    json = JSON.parse(response.body)
    assert_equal "Invalid credentials", json["error"]
  end

  test "should not login admin with nonexistent email" do
    post "/admin/login", params: {
      email: "missing_admin@example.com",
      password: "password123"
    }

    assert_response :unauthorized

    json = JSON.parse(response.body)
    assert_equal "Invalid credentials", json["error"]
  end

  test "should support nested auth parameter for admin" do
    assert_difference("AdminUser.count") do
      post "/admin/register", params: {
        auth: {
          name: "Nested Admin",
          email: "nested_admin@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :created

    json = JSON.parse(response.body)
    assert json["admin"].present?
    assert json["token"].present?
  end
end
