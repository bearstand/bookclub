class CreateCategoryAuthorBookUser < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true do |t|
      t.integer :parent_id

      t.string  :name
    end

    create_table :authors, :force => true do |t|
      t.string  :first_name
      t.string  :initials
      t.string  :last_name
      t.string  :web_url
    end

    create_table :books, :force => true do |t|
      t.string  :title
      t.string  :isbn
      t.string  :language
      t.decimal :price, :precision => 8, :scale => 2
      t.string  :image_url
      t.string  :web_url
      t.string  :status
      t.text    :description

      t.timestamps
    end
    add_index :books, [:title, :isbn], :unique => true
    add_index :books, :status, :unique => false

    create_table :users, :force => true do |t|
      t.string  :webid
      t.string  :handle
      t.string  :upi
      t.string  :csl
      t.string  :password
      t.string  :first_name
      t.string  :initials
      t.string  :last_name
      t.string  :email
      t.string  :phone_number
      t.string  :address
    end
    add_index :users, :webid,  :unique => true

    create_table :categories_books, :id => false do |t|
      t.integer :category_id
      t.integer :book_id
    end
    add_index :categories_books, [:book_id, :category_id], :unique => true
    add_index :categories_books, :category_id, :unique => false

    create_table :authors_books, :id => false do |t|
      t.integer :author_id
      t.integer :book_id
    end
    add_index :authors_books, [:book_id, :author_id], :unique => true
    add_index :authors_books, :author_id, :unique => false
  end

  def self.down
    drop_table :categories
    drop_table :authors
    drop_table :books
    drop_table :users
    drop_table :categories_books
    drop_table :authors_books
  end
end
