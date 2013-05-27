class Resource < ActiveRecord::Base
  belongs_to :book
  belongs_to :owner, :class_name => "User",
                     :foreign_key => "user_id"
  has_many   :readings
end
