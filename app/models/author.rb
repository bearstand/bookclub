class Author < ActiveRecord::Base
  has_and_belongs_to_many :books,
                          :join_table => "authors_books"

  composed_of :name, :class_name => "Name",
                     :mapping =>
                        [ # database    ruby
                         %w[ first_name first ],
                         %w[ initials   initials ],
                         %w[ last_name  last ]
                        ]
end
