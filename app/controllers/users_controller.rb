# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class UsersController < ApplicationController

  load_and_authorize_resource :user

  before_filter :load_locales, except: :index

  def tickets
    @user = User.find(params[:id])
    @tickets = Ticket.filter_by_assignee_id(@user.id)
    @tickets = @tickets.by_status(params[:status]) unless Ticket.statuses[params[:status]].blank?
    @tickets = @tickets.paginate(page: params[:page], per_page: current_user.per_page)
  end

  def stats
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @groups = Group.all
  end

  def update
    @user = User.find(params[:id])

    # if no password was posted, remove from params
    if params[:user][:password] == ''
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if current_user == @user
      params[:user].delete(:agent) # prevent removing own agent permissions
      params[:user].delete(:admin) # prevent removing own aadmin permissions
    end

    if @user.update_attributes(user_params)

      if can? :read, User
        redirect_to users_url, notice: I18n::translate(:settings_saved)
      else
        redirect_to tickets_url, notice: I18n::translate(:settings_saved)
      end

    else
      render action: 'edit'
    end
  end

  def index
    @users = User.ordered.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      if can? :read, User
        redirect_to users_url, notice: I18n::translate(:user_added)
      else
        redirect_to tickets_url, notice: I18n::translate(:user_added)
      end
    else
      render 'new'
    end

  end

  private
    def load_locales
      @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort
      @locales = []

      Dir.open("#{Rails.root}/config/locales").each do |file|
        unless ['.', '..'].include?(file)
          code = file[0...-4] # strip of .yml
          @locales << [I18n.translate(:language_name, locale: code), code]
        end
      end
    end

    def user_params
      attributes = params.require(:user).permit(
          :email,
          :password,
          :password_confirmation,
          :remember_me,
          :signature,
          :agent,
          :admin,
          :notify,
          :time_zone,
          :locale,
          :per_page,
          :contact,
          label_ids: [],
          group_ids: []
      )

      # prevent normal user from changing email and role and group
      unless (current_user.agent? || current_user.admin?)
        attributes.delete(:email)
        attributes.delete(:agent)
        attributes.delete(:admin)
        attributes.delete(:label_ids)
        attributes.delete(:group_ids)
      end

      return attributes
    end

end
