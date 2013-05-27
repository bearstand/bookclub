class Book < ActiveRecord::Base
  LANGUAGE_TYPES = [ nil, "中文", "英文", "混合", "其它" ]

  has_and_belongs_to_many :categories,
                          :join_table => "categories_books"
  has_and_belongs_to_many :authors,
                          :join_table => "authors_books"

  has_many :resources,    :dependent => :delete_all
  has_many :owners,       :through => :resources,
                          :source => :owner,
                          :readonly => true

  has_many :readings,     :dependent => :nullify
  has_many :readers,      :through => :readings,
                          :source => :reader,
                          :readonly => true # attention: how to use

  has_many :attr_entries, :dependent => :delete_all
  has_one  :rating,       :through => :attr_entries,
                          :source => :attr,
                          :source_type => "BookRating",
                          :dependent => :delete

  validates :title, :presence => true

  def quantity
    resources.collect {|x| x.current_quantity}.sum
  end

  def total_quantity
    resources.collect {|x| x.total_quantity}.sum
  end
end
