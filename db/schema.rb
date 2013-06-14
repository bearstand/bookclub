# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110316080516) do

  create_table "attr_entries", :force => true do |t|
    t.integer  "book_id"
    t.integer  "attr_id"
    t.string   "attr_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attr_entries", ["attr_type"], :name => "index_attr_entries_on_attr_type"
  add_index "attr_entries", ["book_id", "attr_type"], :name => "index_attr_entries_on_book_id_and_attr_type"

  create_table "authors", :force => true do |t|
    t.string "first_name"
    t.string "initials"
    t.string "last_name"
    t.string "web_url"
  end

  create_table "authors_books", :id => false, :force => true do |t|
    t.integer "author_id"
    t.integer "book_id"
  end

  add_index "authors_books", ["author_id"], :name => "index_authors_books_on_author_id"
  add_index "authors_books", ["book_id", "author_id"], :name => "index_authors_books_on_book_id_and_author_id", :unique => true

  create_table "book_ratings", :force => true do |t|
    t.decimal "value",        :precision => 2, :scale => 1
    t.integer "rating_count"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "isbn"
    t.string   "language"
    t.decimal  "price",       :precision => 8, :scale => 2
    t.string   "image_url"
    t.string   "web_url"
    t.string   "status"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["status"], :name => "index_books_on_status"
  add_index "books", ["title", "isbn"], :name => "index_books_on_title_and_isbn", :unique => true

  create_table "categories", :force => true do |t|
    t.integer "parent_id"
    t.string  "name"
  end

  create_table "categories_books", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "book_id"
  end

  add_index "categories_books", ["book_id", "category_id"], :name => "index_categories_books_on_book_id_and_category_id", :unique => true
  add_index "categories_books", ["category_id"], :name => "index_categories_books_on_category_id"

  create_table "readings", :force => true do |t|
    t.integer  "resource_id"
    t.integer  "book_id"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "read_at"
    t.datetime "return_at"
    t.decimal  "rating",      :precision => 2, :scale => 1
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "readings", ["book_id", "read_at"], :name => "index_readings_on_book_id_and_read_at"
  add_index "readings", ["book_id", "user_id"], :name => "index_readings_on_book_id_and_user_id"
  add_index "readings", ["user_id"], :name => "index_readings_on_user_id"

  create_table "resources", :force => true do |t|
    t.integer "book_id"
    t.integer "user_id"
    t.integer "current_quantity"
    t.integer "total_quantity"
  end

  add_index "resources", ["book_id", "user_id"], :name => "index_resources_on_book_id_and_user_id"
  add_index "resources", ["user_id"], :name => "index_resources_on_user_id"

  create_table "users", :force => true do |t|
    t.string "webid"
    t.string "handle"
    t.string "upi"
    t.string "csl"
    t.string "hashed_password"
    t.string "first_name"
    t.string "initials"
    t.string "last_name"
    t.string "email"
    t.string "phone_number"
    t.string "address"
  end

  add_index "users", ["webid"], :name => "index_users_on_webid", :unique => true

end
