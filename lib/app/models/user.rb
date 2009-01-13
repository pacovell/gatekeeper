class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation
  
  has_many :user_roles
  has_many :roles, :through => :user_roles, :uniq => true
  
  before_create :first_user_is_admin
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validate :username_valid
  
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :password_key, :allow_nil => true
  
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validate :password_non_blank, :password_not_stupid
   
  def self.authenticate(username, password)
    return nil if username.blank? || password.blank?
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  def set_password_key!
    self.password_key = gen_key
    self.password_key_created_at = Time.now
    save!
  end
  
  def clear_password_key!
    self.password_key = nil
    self.password_key_created_at = nil
    save!
  end
      
  # 'password' is a virtual attribute
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  # Returns nil if no role is found, returns the role if it is found and added
  def add_role(role)
    role = Role.find_by_tag(role) if role.class == String
    if role
      self.roles << role
    end
    role
  end
  
  # Returns nil if no role is found, returns the role if it is found and removed
  def remove_role(role)
    role = Role.find_by_tag(role) if role.class == String
    if role
      self.roles.delete(role)
    end
    role
  end
  
  def has_privilege?(privilege)
    # Administrator has all privileges
    return true if self.roles.find_by_tag("admin")
    
    if privilege.class == Privilege
      privilege_id = privilege.id
    elsif privilege.class == String
      privilege = Privilege.find_by_tag(privilege)
      privilege_id = privilege.id if privilege
    end
    
    return false if privilege_id.nil?

    # TODO: highly inefficient -- make a big join
    self.roles.each do |role|
      if role.privileges.find(:first, :conditions => "id = #{privilege_id}")
        return true
      end
    end
    return false
  end
    
  private
  
  def password_non_blank
    errors.add_to_base("Missing password" ) if hashed_password.blank?
  end
  
  def username_valid
    return if username.nil?
    
    if (username.length < 4) then
      errors.add(:username, "must be at least 4 characters")
    end
    if (username =~ /^[A-Za-z]/) == nil then
      errors.add(:username, "must start with a letter")
    end
    if username =~ /\W/ then
      errors.add(:username, "must be alphanumerical with no spaces") 
    end
  end
  
  def password_not_stupid
    return if @password.nil?
    
    if (@password.length < 4) then
      errors.add_to_base("Password must be at least 4 characters")
    end
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "colorad0" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  # Generates a pseudo-random string in hex format (0..9+A..F)
  # which contains chunk*16 bits of randomness.
  def gen_key(chunks=2)
    ("%04x"*chunks % ([nil]*chunks).map { rand(2**16) }).upcase
  end
  
  def first_user_is_admin
    if User.count(:all) == 0
      role = Role.find_by_tag("admin")
      if Role.find_by_tag("admin").nil?
        role = Role.new
        role.tag = "admin"
        role.name = "Administrator"
        role.description = "Administrator role"
        role.save!
      end
      self.add_role("admin")
    end
  end  
      
end
