class Category < ActiveRecord::Base
  has_and_belongs_to_many :books,
                          :join_table => "categories_books"

  # acts_as_tree :order => "name"
end
