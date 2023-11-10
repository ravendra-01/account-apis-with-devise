# frozen_string_literal: true
require 'httparty'
require 'json'
class Users::SessionsController < Devise::SessionsController
  include HTTParty
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if params[:login_type] == "social"
      url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params["id_token"]}"                  
      response = HTTParty.get(url)                   
      @user = User.create_user_for_google(response.parsed_response)
      # debugger 
      # tokens = @user.create_new_auth_token                      
      @user.save
      respond_with @user
      # render json: {
      #   status: { code: 200, messages: "User signed in successfully", data: @user}
      # }
    else
      super
    end
  end
  

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  respond_to :json

  private

  def respond_with(resource, options={})
    if resource.persisted?
      render json: {
        status: { code: 200, messages: "User signed in successfully", data: resource}
      }
    else
      render json: {
        status: { messages: "User could not be signed in successfully",
            errors: resource.errors.full_messages}
      }, status: :unprocessable_entity
    end
  end

  def respond_to_on_destroy
    jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], 
                  Rails.application.credentials.fetch(:secret_key_base)).first
    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        messages: "Signed out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        messages: "User has no active session"
      }, status: :unauthorized
    end
  end
end
