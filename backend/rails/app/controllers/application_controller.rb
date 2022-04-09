class ApplicationController < ActionController::API
  before_action :authorized

  JWTKey = Rails.application.credentials.jwt_key
  private_constant :JWTKey

  def encode_token(payload)
    JWT.encode(payload, JWTKey)
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    return if !auth_header

    token = auth_header.split(/\s+/).last
    begin
      JWT.decode(token, JWTKey, true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end
  end

  def logged_in_user
    return if !decoded_token

    user_id = decoded_token[0]['user_id']
    @user = User.find_by(id: user_id)
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
