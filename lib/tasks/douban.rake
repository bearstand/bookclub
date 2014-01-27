require 'rexml/document'

namespace :douban do
  desc "image download from douban"
  task :image_download => :environment do
    include ApplicationHelper

    image_path = Rails.root.to_s + '/public/images/'
    isbn_url  = 'http://api.douban.com/book/subject/isbn/'

    # for regular user, douban's API limitation:
    # no more than 10 times per minutes, so we 
    # define internal time as 7 seconds
    internal    = 10

    # counter = 0
    Book.where("image_url is NULL" ).each do |b| 
      # check that the real image file does exist,
      # otherwise the file need to download, too.
      if (b.image_url && File.exists?(image_path + b.image_url) || !(b.isbn =~ /^[A-Za-z0-9-]+$/))
        next
      end

      sleep(internal)

      image_url = nil
      next unless res = fetch(isbn_url + b.isbn.delete('-'))

      doc = REXML::Document.new(res.body)
      REXML::XPath.each(doc, "//link") { |link|
        if (link.attributes['rel'] == 'image')
          image_url = link.attributes['href']
        end
      }

      if image_url
        next unless res = fetch(image_url)

        book_image_path = 'books/book_' + b.id.to_s + File.extname(image_url)
        f = File.new(image_path + book_image_path, "w", 0644)
        f.write(res.body)
        f.close

        b.image_url = book_image_path
        b.save
      end

    end
  end

  desc "web_url from douban"
  task :web_url_retrieve => :environment do
    include ApplicationHelper

    isbn_url  = 'http://api.douban.com/book/subject/isbn/'

    # for regular user, douban's API limitation:
    # no more than 10 times per minutes, so we 
    # define internal time as 10 seconds
    internal    = 10

    # counter = 0
    Book.all.each do |b|
      if ((b.web_url && !b.web_url.empty?) || !(b.isbn =~ /^[A-Za-z0-9-]+$/))
        next
      end

      # below 'elapsed' should be put near 'each' to make timer accurate
      sleep(internal)

      web_url = nil
      next unless res = fetch(isbn_url + b.isbn.delete('-'))

      doc = REXML::Document.new(res.body)
      REXML::XPath.each(doc, "//link") { |link|
        if (link.attributes['rel'] == 'alternate')
          web_url = link.attributes['href']
        end
      }

      if web_url
        b.web_url = web_url
        b.save
      end

      # counter = counter + 1
      # break if counter == 10 

    end
  end

  desc "douban tasks: need an intersect of image and web_url to improve efficiency" + 
       " that they could be done in only one douban api access"
  task :all => [ :image_download, :web_url_retrieve ]
end
