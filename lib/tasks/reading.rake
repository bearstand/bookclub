

namespace :reading do
  desc "Pick all overdue readings"
  task :overdue_readings => :environment do
    d = 60.days.ago.to_date
    readings = Reading.find(:all,
                            :include => [ :resource ],
                            :conditions => [ "return_at is null and read_at < ?", d.to_s(:db) ])
    puts "-------------- begin overdue readings ---------------\n"
    readings.each do |r|
      if ! r.resource
        next
      end

      puts "Reader: #{r.reader.name}"
      puts "Book: #{r.book.title}"
      puts "Owner: #{r.resource.owner.name}"
      overdue_days = (d - r.read_at.to_date).to_i
      Mailer.overdue_readings(r.reader,
                              r.resource.owner,
                              r.book,
                              overdue_days).deliver
    end
    puts "--------------- end overdue readings ----------------\n\n"
  end

  desc "Pick all nearly overdue readings"
  task :nearly_overdue_readings => :environment do
    d1 = 60.days.ago.to_date
    d2 = 53.days.ago.to_date
    readings = Reading.find(:all,
                            :include => [ :resource ],
                            :conditions => [ "return_at is null and read_at > ? and read_at <= ?", d1.to_s(:db), d2.to_s(:db) ])
    puts "----------- begin nearly overdue readings -----------\n"
    readings.each do |r|
      if ! r.resource
        next
      end

      puts "Reader: #{r.reader.name}"
      puts "Book: #{r.book.title}"
      puts "Owner: #{r.resource.owner.name}"
      nearly_overdue_days = (r.read_at.to_date - d1).to_i
      Mailer.nearly_overdue_readings(r.reader,
                                     r.resource.owner,
                                     r.book,
                                     nearly_overdue_days).deliver
    end
    puts "------------ end nearly overdue readings ------------\n\n"
  end
 
  desc "overall tasks"
  task :all => [ :overdue_readings, :nearly_overdue_readings ]
end
