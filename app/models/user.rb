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

class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings
  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :templates, :class_name => ::Template

  # identities for omniauth
  has_many :identities

  scope :admins, -> {
    where(admin: true)
  }

  scope :agents, -> {
    where(agent: true)
  }

  scope :ordered, -> {
    order(:email)
  }

  scope :by_email, ->(email) {
    where('LOWER(email) LIKE ?', '%' + email.downcase + '%')
  }

  scope :group_members, ->(group_id) {
   joins(:groups).where("groups.id = ?", group_id)
  }

  def customer?
    !(agent? || admin?)
  end

  def self.agents_to_notify(group_id = nil)
    users = User.agents.where(notify: true)
    users = users.group_members(group_id) if group_id
    users
  end
end
