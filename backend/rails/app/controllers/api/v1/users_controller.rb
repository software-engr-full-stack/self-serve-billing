class Api::V1::UsersController < ApplicationController
  before_action :authorized, except: %i[sign_up login]

  def sign_up
    @user = User.create(user_params)
    if @user.valid?
      token = encode_token(user_id: @user.id)
      render json: { user: @user, jwt: token }
    else
      render json: { error: 'Invalid inputs' }
    end
  end

  def login
    @user = User.find_by(email: user_params[:email])

    if @user && @user.authenticate(user_params[:password])
      token = encode_token(user_id: @user.id)
      render json: { user: @user, jwt: token }
    else
      render json: { error: 'Invalid inputs' }
    end
  end

  def verify
    render json: @user
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :name, :notes)
  end
end
