class Role < ActiveRecord::Base
  validates_presence_of :tag
  validates_uniqueness_of :tag
  validate :tag_format
  
  has_many :role_privileges
  has_many :privileges, :through => :role_privileges, :uniq => true
  
  attr_accessible :name, :description
  
  protected
  
  def tag_format
    if tag =~ /\s/
      errors.add(:tag, "Tag must not contain spaces")
    end
  end
  
end