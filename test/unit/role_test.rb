require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  def test_requirements
    r = Role.new
  
    # Tag is required
    assert !r.valid?
    r.tag = 'test_role'
    assert r.valid?
  end

  def test_duplicate_tag
    r = Role.new
    r.tag = 'test_role'
    r.save!
    r2 = Role.new
    r.tag = 'test_role'
    assert !r2.valid?
    r2.tag = 'test_role_2'
    assert r2.valid?
  end
  
  def test_bad_tag
    bad_tags = [" abc", "ab cd"]
    good_tags = ["1", "abc&ds"]
    r = Role.new
    
    assert !r.valid?
    good_tags.each do |tag|
      r.tag = tag
      assert r.valid?
    end
    
    bad_tags.each do |tag|
      r.tag = tag
      assert !r.valid?
    end
  end

  def test_add_and_remove_privileges
    r = roles(:admin)
    assert_equal 0, r.privileges.count
    p1 = privileges(:edit_other_users)
    r.privileges << p1
    assert_equal 1, r.privileges.count
    p2 = privileges(:edit_others_articles)
    r.privileges << p2
    assert_equal 2, r.privileges.count
    
    # Duplicate should not add a second entry
    r.privileges << p2
    assert_equal 2, r.privileges.count
    
    assert_equal p1, r.privileges.find(p1)
    
    r.privileges.delete(p1)
    assert_raise (ActiveRecord::RecordNotFound) {r.privileges.find(p1)}
    assert_equal 1, r.privileges.count
  end

end