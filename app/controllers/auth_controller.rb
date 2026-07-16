class AuthController < ApplicationController
  def register_user
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode({ user_id: user.id, type: "User" })
      render json: { user: serialize_user(user), token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login_user
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode({ user_id: user.id, type: "User" })
      render json: { user: serialize_user(user), token: token }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def login_admin
    admin = AdminUser.find_by(email: params[:email])
    if admin&.authenticate(params[:password])
      token = JsonWebToken.encode({ user_id: admin.id, type: "AdminUser" })
      render json: { admin: serialize_admin(admin), token: token }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  private

  def user_params
    if params[:auth].present?
      params.require(:auth).permit(:name, :email, :password, :password_confirmation)
    else
      params.permit(:name, :email, :password, :password_confirmation)
    end
  end

  def admin_params
    if params[:auth].present?
      params.require(:auth).permit(:name, :email, :password, :password_confirmation)
    else
      params.permit(:name, :email, :password, :password_confirmation)
    end
  end

  def serialize_user(user)
    user.slice(:id, :name, :email)
  end

  def serialize_admin(admin)
    admin.slice(:id, :name, :email)
  end
end
