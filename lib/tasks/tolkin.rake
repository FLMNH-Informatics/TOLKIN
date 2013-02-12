#require 'active_record'
#require 'db/schema_supplement'
#
#namespace :tolkin do
#  namespace :db do
#    namespace :test do
#      task :prepare do
#        Rake::Task["db:test:prepare"].invoke
#        SchemaSupplement.up
#      end
#    end
#  end
#  namespace :images do
#    desc "Rebuild all thumb images made by attachment_fu"
#    task :rebuild_thumbnails => :environment do
#      conditions =  ""
#      count = Image.count(:all) #, :conditions => conditions) # image is an attachment_fu model
#      done = 0
#      chunk_size = 500
#      (0...(count.to_f/chunk_size).ceil).each do |i|
#        Image.all(:offset => i*chunk_size, :limit => chunk_size).each do |image| # :conditions => conditions
#          puts "starting"
#          done = done + 1
#          # next if image.id < 46520 #  to resume a stopped run
#          image.remake_thumbnails!
#          percent = "%.2f" % ((done/count.to_f)*100)
#          puts "#{i} #{percent}% done"
#        end
#      end
#    end
#  end
#end
