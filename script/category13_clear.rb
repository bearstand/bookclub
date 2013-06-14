# OBJECTIVE
# For books in category 13 (suggested to buy), clear their resources.

# EXPLANATION: when a book of category 13 is being added, no resources will be added
# for the book. However, when a user adds the book into another category mistakenly
# and change it back to category 13, the resources have not been cleared.
#
# HOWTO
# 1. cd application directory, e.g: cd /home/tools/njc_bookclub
# 2. rails runner 'script/category13_clear.rb'

Category.find(13).books.each do |b|
  res = b.resources
  if ! res.empty?
    res.each do |r|
      print "resource id: " + r.id.to_s + ' '
      print "book id: "     + b.id.to_s + ' '
      print "book title: "  + b.title.to_s + "\n"

      # destroy readings of this resource, since they are invalid
      r.readings.each do |reading|
        print "\treading id: " + reading.id.to_s + "\n"
        reading.destroy
      end
      print "\n"
      r.destroy
    end
  end
end
