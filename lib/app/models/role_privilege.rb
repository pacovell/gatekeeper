class RolePrivilege < ActiveRecord::Base
  validates_presence_of :role_id, :privilege_id
  
  belongs_to :role
  belongs_to :privilege
  
end