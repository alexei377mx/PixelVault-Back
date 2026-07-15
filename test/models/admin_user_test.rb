require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  setup do
    @admin = admin_users(:one)
  end

  test "should be valid with valid attributes" do
    assert @admin.valid?
  end

  test "should not be valid without name" do
    @admin.name = nil
    assert_not @admin.valid?
  end

  test "should not be valid without email" do
    @admin.email = nil
    assert_not @admin.valid?
  end

  test "should not be valid with invalid email format" do
    @admin.email = "invalid-email"
    assert_not @admin.valid?
  end

  test "should not be valid with duplicate email" do
    duplicate_admin = @admin.dup
    duplicate_admin.email = @admin.email
    assert_not duplicate_admin.valid?
  end

  test "should not be valid with short password" do
    @admin.password = "12345"
    @admin.password_confirmation = "12345"
    assert_not @admin.valid?
  end

  test "should authenticate with correct password" do
    assert @admin.authenticate("password123")
  end

  test "should not authenticate with wrong password" do
    assert_not @admin.authenticate("wrongpassword")
  end

  test "should save with valid data" do
    new_admin = AdminUser.new(
      name: "Test Admin",
      email: "testadmin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert new_admin.save
  end

  test "password_digest should be present after save" do
    new_admin = AdminUser.new(
      name: "Secure Admin",
      email: "secure@example.com",
      password: "securepass123",
      password_confirmation: "securepass123"
    )
    new_admin.save
    assert_not_nil new_admin.password_digest
  end
end
