class TemplatesController < ApplicationController

  load_and_authorize_resource :template

  before_action :set_template, only: [:show, :edit, :update, :destroy]

  respond_to :html, :json

  def index
    @templates = Template.paginate(page: params[:page]).all
    respond_with(@templates)
  end

  def show
    respond_with(@template)
  end

  def new
    @template = Template.new
    respond_with(@template)
  end

  def edit
  end

  def create
    @template = Template.new(template_params)
    @template.save
    respond_with(@template)
  end

  def update
    @template.update(template_params)
    respond_with(@template)
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
