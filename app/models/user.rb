class User < ActiveRecord::Base
  has_many :resources,    :dependent => :delete_all
  has_many :books,        :through => :resources,
                          :source => :book,
                          :readonly => true

  has_many :readings,     :dependent => :nullify
  has_many :read_books,   :through => :readings,
                          :source => :book,
                          :readonly => true

  composed_of :name, :class_name => "Name",
                     :mapping =>
                        [ # database    ruby
                         %w[ first_name first ],
                         %w[ initials   initials ],
                         %w[ last_name  last ]
                        ]

  attr_accessor :password_confirmation
  attr_reader   :password

  after_destroy :ensure_an_admin_remains

  validates :webid, :presence => true, :uniqueness => true
  validates :email, :presence => true
  validates :password, :confirmation => true
  validates_format_of  :email, :message => "Email with incorrect Format", :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i  
  validate  :password_must_be_present

  def User.authenticate(webid, password)
    if user = find_by_webid(webid)
      salt = user.hashed_password[0, 2]      
      if user.hashed_password == encrypt_password(password, salt)
        user
      end
    end
  end

  def User.encrypt_password(password, salt)
    # Data_Encryption_Standard
    password.crypt(salt)
  end

  # 'password' is a virtual attribute
  def password=(password)
    @password = password

    if password.present?
      salt = rand(100).to_s[0, 2]
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  def ensure_an_admin_remains
    if User.count.zero?
      raise "Can't delete last user"
    end
  end

private
  def password_must_be_present
      errors.add(:password, "Missing password") unless hashed_password.present?
  end
end
