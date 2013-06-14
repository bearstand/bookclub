class CreateAttrEntry < ActiveRecord::Migration
  def self.up
    create_table :attr_entries, :force => true do |t|
      t.integer   :book_id

      t.integer   :attr_id
      t.string    :attr_type

      t.timestamps
    end
    add_index :attr_entries, [:book_id, :attr_type], :unique => false
    add_index :attr_entries, :attr_type, :unique => false
  end

  def self.down
    drop_table :attr_entries
  end
end
