class TemplatesController < ApplicationController

  load_and_authorize_resource :template

  before_action :set_template, only: [:edit, :update, :destroy]

  respond_to :html, :json

  def index
    @templates = Template.paginate(page: params[:page]).all
    respond_with(@templates)
  end

  def new
    @template = Template.new
    respond_with(@template)
  end

  def edit
  end

  def create
    @template = Template.new(template_params)
    if @template.save
      redirect_to templates_path, notice: t(:template_created)
    else
      render :new
    end
  end

  def update
    if @template.update(template_params)
      redirect_to templates_path, notice: t(:template_modified)
    else
      render :edit
    end
  end

  def destroy
    @template.destroy
    respond_with(@template)
  end

  private
  def set_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:title, :description, :content)
  end
end
