class MembersOnlyArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authorize
  skip_before_action :authorize, only: [:index]

  def index
    if authorized?
      articles = Article.where(is_member_only: true).includes(:user).order(created_at: :desc)
      render json: articles, each_serializer: ArticleListSerializer
    else
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end

  def show
    article = Article.find(params[:id])
    render json: article
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

  def authorize
    return render json: { error: "Not authorized" }, status: :unauthorized unless session.include?(:user_id)
  end

  def authorized?
    session[:user_id].present?
  end
end
