# -*- coding: utf-8 -*-
class Mailer < ActionMailer::Base
  default :from => "library manager<no-reply@tomato.cn.lucent.com>"

  def welcome(user)
    @user = user
    @url = "http://tomato.cn.lucent.com/njcbc/login"
    mail(:to => user.email,
         :subject => "Welcome to Nanjing center book club")
  end

  def lend_in(reader, owner, book)
    lend_book reader, owner, book, "向您借阅图书："
  end

  def lend_cancel(reader, owner, book)
    lend_book reader, owner, book, "取消了向您借阅的图书："
  end

  def lend_return(reader, owner, book)
    lend_book reader, owner, book, "归还了向您借阅的图书："
  end

  def lend_reserve(reader, owner, book, current_readers)
    @reader = reader
    @owner  = owner
    @book   = book
    @current_readers = current_readers

    # email = "guo_ping.luo@alcatel-lucent.com"
    # mail(:to => email,
    #      :cc => email,
    #      :subject => "#{reader.name} 向您预借图书： #{book.title}")

    unless (reader.email.nil? || reader.email.empty? ||
            owner.email.nil? || owner.email.empty?)
      mail(:to => owner.email,
           :cc => [ reader.email ].concat((@current_readers.collect {|r| r.email}) || [ ]),
           :subject => "#{reader.name} 向您预借图书： #{book.title}")
    end
  end

  def overdue_readings(reader, owner, book, overdue_days)
    @reader = reader
    @owner  = owner
    @book   = book
    @overdue_days = overdue_days

    # email = "guo_ping.luo@alcatel-lucent.com"
    # mail(:to => email,
    #      :cc => email,
    #      :subject => "#{reader.name} 借阅的图书： " +
    #      "#{book.title} 逾期 #{overdue_days} 天")

    unless (reader.email.nil? || reader.email.empty? ||
            owner.email.nil? || owner.email.empty?)
      mail(:to => reader.email,
           :cc => owner.email,
           :subject => "#{reader.name} 借阅的图书： " +
                       "#{book.title} 逾期 #{overdue_days} 天")
    end
  end

  def nearly_overdue_readings(reader, owner, book, nearly_overdue_days)
    @reader = reader
    @owner  = owner
    @book   = book
    @nearly_overdue_days = nearly_overdue_days

    # email = "guo_ping.luo@alcatel-lucent.com"
    # mail(:to => email,
    #      :cc => email,
    #      :subject => "#{reader.name} 借阅的图书： " +
    #      "#{book.title} 距离逾期剩余 #{nearly_overdue_days} 天")

    unless (reader.email.nil? || reader.email.empty? ||
            owner.email.nil? || owner.email.empty?)
      mail(:to => reader.email,
           :cc => owner.email,
           :subject => "#{reader.name} 借阅的图书： " +
                       "#{book.title} 距离逾期剩余 #{nearly_overdue_days} 天")
    end
  end

  def reset_password(user, password)
    @user = user
    @password = password

    unless user.email.nil?
      mail(:to => user.email,
           :subject => "#{user.name} ：您的密码已经重置")
    end
  end

protected
  def lend_book(reader, owner, book, msg)
    @reader = reader
    @owner  = owner
    @book   = book

    unless (reader.email.nil? || reader.email.empty? ||
            owner.email.nil? || owner.email.empty?)
      mail(:to => owner.email, 
           :cc => reader.email,
           :subject => "#{reader.name} #{msg} #{book.title}")
    end
  end

end
