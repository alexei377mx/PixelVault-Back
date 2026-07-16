class FavoritesController < ApplicationController
  before_action :authenticate_user

  def index
    render json: current_user.favorites
  end

  def create
    favorite = current_user.favorites.new(
      game_id: params[:game_id]
    )

    if favorite.save
      render json: favorite, status: :created
    else
      render json: {
        errors: favorite.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    favorite = current_user.favorites.find_by(
      game_id: params[:id]
    )

    return head :not_found unless favorite

    if params[:category_id].present? && !Category.exists?(id: params[:category_id])
      return render json: {
        error: "Category not found"
      }, status: :not_found
    end

    if favorite.update(category_id: params[:category_id])
      render json: favorite
    else
      render json: {
        errors: favorite.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    favorite = current_user.favorites.find_by(
      game_id: params[:id]
    )

    return head :not_found unless favorite

    favorite.destroy

    head :no_content
  end
end
