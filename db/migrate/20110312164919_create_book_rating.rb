class CreateBookRating < ActiveRecord::Migration
  def self.up
    create_table :book_ratings, :force => true do |t|
      t.decimal :value, :precision => 2, :scale => 1
      t.integer :rating_count
    end
  end

  def self.down
    drop_table :book_ratings
  end
end
