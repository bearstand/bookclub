class CreateReadingResource < ActiveRecord::Migration
  def self.up
    create_table :resources, :force => true do |t|
      t.integer :book_id
      t.integer :user_id

      t.integer :current_quantity
      t.integer :total_quantity
    end
    add_index :resources, [:book_id, :user_id], :unique => false
    add_index :resources, :user_id, :unique => false

    create_table :readings, :force => true do |t|
      t.integer :resource_id
      t.integer :book_id
      t.integer :user_id

      t.string  :status
      t.timestamp :read_at
      t.timestamp :return_at
      t.decimal :rating, :precision => 2, :scale => 1
      t.text    :comment

      t.timestamps
    end
    add_index :readings, [:book_id, :user_id], :unique => false
    add_index :readings, [:book_id, :read_at], :unique => false
    add_index :readings, :user_id, :unique => false
  end

  def self.down
    drop_table :resources
    drop_table :readings
  end
end
