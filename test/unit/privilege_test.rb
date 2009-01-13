require 'test_helper'

class PrivilegeTest < ActiveSupport::TestCase
  
  def test_requirements
    p = Privilege.new
    
    # Tag is required
    assert !p.valid?
    p.tag = 'test_privilege'
    assert p.valid?
  end
  
  def test_duplicate_tag
    p = Privilege.new
    p.tag = 'test_privilege'
    p.save!
    p2 = Privilege.new
    p2.tag = 'test_privilege'
    assert !p2.valid?
    p2.tag = 'test_privilege_2'
    assert p2.valid?
  end
  
  def test_bad_tag
    bad_tags = [" abc", "ab cd"]
    good_tags = ["1", "abc&ds"]
    p = Privilege.new
    
    assert !p.valid?
    good_tags.each do |tag|
      p.tag = tag
      assert p.valid?
    end
    
    bad_tags.each do |tag|
      p.tag = tag
      assert !p.valid?
    end
  end
  
end
