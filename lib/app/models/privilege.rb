class Privilege < ActiveRecord::Base
  validates_presence_of :tag
  validates_uniqueness_of :tag
  validate :tag_format
    
  attr_accessible :name, :description
  
  protected
  
  def tag_format
    if tag =~ /\s/
      errors.add(:tag, "Tag must not contain spaces")
    end
  end
  
end