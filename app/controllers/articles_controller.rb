class ArticlesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :article, except: [:create]
  skip_authorization_check only: :create

  def show
    @labeling = Labeling.new(labelable: @article)
  end

  def new
  end

  def index
    @articles = @articles.search(params[:q])
    .by_label_id(params[:label_id])

    @articles = params[:sort].blank? ? @articles.ordered : @articles.sorted(params[:sort], params[:direction])

    respond_to do |format|
      format.html do
        @articles = @articles.paginate(page: params[:page],
                                     per_page: current_user.per_page)
      end
    end
  end

  def edit
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to article_path(@article), notice: t(:article_created)
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to article_path(@article), notice: t(:article_modified)
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    respond_with(@article)
  end

  private
  def article_params
    params.require(:article).permit(:title, :description, :body, :labels_list)
  end

end
