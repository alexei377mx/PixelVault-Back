class ApplicationController < ActionController::API
  def authenticate_user
    authenticate_with_type("User")
  end

  def authenticate_admin
    authenticate_with_type("AdminUser")
  end

  def current_user
    @current_user
  end

  def current_admin
    @current_admin
  end

  private

  def authenticate_with_type(model_type)
    header = request.headers["Authorization"]
    token = header&.split&.last

    return render_unauthorized unless token

    decoded = JsonWebToken.decode(token)
    return render_unauthorized unless decoded

    if decoded[:type] != model_type
      return render_forbidden
    end

    model = model_type.constantize.find_by(id: decoded[:user_id])
    return render_unauthorized unless model

    if model_type == "User"
      @current_user = model
    else
      @current_admin = model
    end
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
