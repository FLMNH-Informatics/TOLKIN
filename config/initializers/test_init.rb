#class ActiveRecord::Base
#  def self.default_scoping= value
#    debugger
#    @default_scoping = value
#  end
#
##  def self.scoped_methods #:nodoc:
##    debugger
##    key = :"#{self}_scoped_methods"
##    Thread.current[key] = Thread.current[key].presence || self.default_scoping.dup
##  end
#end