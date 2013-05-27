class Reading < ActiveRecord::Base
  RATING_NUMBERS = [ nil, 5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0 ]

  belongs_to :resource
  belongs_to :book
  belongs_to :reader, :class_name => "User",
                      :foreign_key => "user_id"

  def reading_status()
    if status=="suggest"
      "SUGGEST"
    elsif read_at.nil?
      "RESERVED"
    elsif return_at.nil?
      "READING"
    else
      "RETURNED"
    end
  end
end
