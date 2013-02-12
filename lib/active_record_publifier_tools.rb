=begin
   Controller mixin module for working with collections
   with Activerecord Public Records initializer
   basically makes any AR object in an array public or private
=end
module ActiveRecordPublifierTools
=begin
  module Enumerable
    #
    #
    # Will make any AR object public
    # and any AR objects in an array public
    ####
    def make_records_public
      if self.is_a?(Array) && !self.empty? #&& self.first.is_a?(ActiveRecord)
        self.each{|record| record.make_public if record.is_a?(ActiveRecord)}
      end

      if self.is_a?(ActiveRecord)
         self.make_public
      end
      self
    end
    alias :publicize :make_records_public
    #
    #
    #
    ####
    def make_records_private
      if self.is_a?(Array) && !self.empty? #&& self.first.is_a?(ActiveRecord)
        self.each{|record| record.make_private if record.is_a?(ActiveRecord)}
      end

      if self.is_a?(ActiveRecord)
        self.make_private
      end
      self
    end
    alias :privatize :make_records_private
    #
    #
  end
=end
end
