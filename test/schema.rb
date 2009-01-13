ActiveRecord::Schema.define(:version => 0) do
  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "password_key"
    t.datetime "password_key_created_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "tag"
    t.text     "description"
  end
  
  create_table "privileges", :force => true do |t|
    t.string   "name"
    t.string   "tag"
    t.text     "description"
  end
  
  create_table "role_privileges", :force => true, :id => false do |t|
    t.integer   "role_id", :null => false
    t.integer   "privilege_id", :null => false
  end

  create_table "user_roles", :force => true, :id => false do |t|
    t.integer   "user_id", :null => false
    t.integer   "role_id", :null => false
  end

end