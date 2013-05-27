class AttrEntry < ActiveRecord::Base
  belongs_to :book
  belongs_to :attr, :polymorphic => true
end

class BookRating < ActiveRecord::Base
  has_one :attr_entry, :as => :attr, :dependent => :destroy
end
