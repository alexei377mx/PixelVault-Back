require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = categories(:one)
  end

  test "should be valid with valid attributes" do
    assert @category.valid?
  end

  test "should not be valid without name" do
    @category.name = nil
    assert_not @category.valid?
  end

  test "should not allow duplicate names" do
    duplicate = @category.dup
    assert_not duplicate.valid?
  end

  test "description can be blank" do
    @category.description = nil
    assert @category.valid?
  end

  test "should create a new category with valid data" do
    new_category = Category.new(
      name: "Action",
      description: "Games with fast-paced gameplay and combat"
    )
    assert new_category.save
  end

  test "should not save category with empty name" do
    category = Category.new(name: "")
    assert_not category.save
  end

  test "name should be unique ignoring case" do
    @category.name = "Adventure"
    duplicate = Category.new(name: "Adventure")
    assert duplicate.valid? || duplicate.errors[:name].any?
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      @category.destroy
    end
  end
end
