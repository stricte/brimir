class UserGroup < ActiveRecord::Base

  validates_presence_of :user_id, :group_id

  belongs_to :user
  belongs_to :group
end
