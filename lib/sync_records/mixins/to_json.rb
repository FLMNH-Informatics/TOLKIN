#module SyncRecords
#  module Mixins
#    module ToJson
#      def to_json options
#        Restful::JsonFormatter.new.format(self, options)
#      end
#    end
#  end
#end