class UserRole < ActiveRecord::Base
  validates_presence_of :user_id, :role_id
  
  belongs_to :user
  belongs_to :role
  
end