class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :default

  has_many :tickets
end
