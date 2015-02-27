class GroupsController < ApplicationController

  load_and_authorize_resource :group
  respond_to :html

  def index
    @groups = Group.paginate(page: params[:page]).all
    respond_with(@groups)
  end

  def new
    @group = Group.new
    respond_with(@group)
  end

  def edit
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private
  def group_params
    params.require(:group).permit(:name, :description, :default)
  end
end
