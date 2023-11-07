class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_post, only: [:update, :show, :destroy]

  def index
    @posts = Post.all
    # render json: @posts
    render json: PostSerializer.new(@posts).serializable_hash, status: :ok
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      render json: PostSerializer.new(@post).serializable_hash, status: :created
    else
      render json: {error: "Post not created"}, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: PostSerializer.new(@post).serializable_hash, status: :ok
    else
      render json: {error: "Post not updated"}, status: :unprocessable_entity
    end
  end

  def show
    render json: PostSerializer.new(@post).serializable_hash, status: :ok
  end

  def destroy
    if @post.destroy
      render json: {error: "Post deleted successfully"}, status: :ok
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :description)
  end

  def get_post
    @post = current_user.posts.find_by(id: params[:id])
    return render json: {error: "Post not found"}, status: :not_found unless @post
  end

  # def validate_user
  #   if request.headers['Authorization']
  #     begin
  #       jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], 
  #                     Rails.application.credentials.fetch(:secret_key_base)).first
  #     rescue JWT::ExpiredSignature => e
  #       return render json: { status: 401, messages: e.message
  #         }, status: :unauthorized
  #     end
  #     current_user = User.find(jwt_payload['sub'])
  #     return render json: { status: 401, messages: "User has no active session"
  #     }, status: :unauthorized unless current_user
  #   else
  #     render json: {
  #         status: 401,
  #         messages: "Authorization Token Not Found"
  #       }, status: :unauthorized
  #   end
  # end
end
