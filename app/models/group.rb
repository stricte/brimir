class Group < ActiveRecord::Base
  validates_presence_of :name
  validates :default, :uniqueness => {:if => :default?}

  has_many :tickets

  scope :viewable_by, lambda { |user|
    where(id: user.group_ids) unless user.admin?
  }

end
