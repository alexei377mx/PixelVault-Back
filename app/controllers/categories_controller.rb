class CategoriesController < ApplicationController
  before_action :authenticate_admin, except: [ :index ]
  before_action :set_category, only: [ :update, :destroy ]

  def index
    @categories = Category.all
    render json: @categories, status: :ok
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      render json: @category, status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, status: :ok
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Category not found" }, status: :not_found
  end

  def category_params
    if params[:category].present?
      params.require(:category).permit(:name, :description)
    else
      params.permit(:name, :description)
    end
  end
end
