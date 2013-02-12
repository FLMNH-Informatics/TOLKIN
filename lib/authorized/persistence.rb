module Authorized
  module Persistence
    def self.included(klass)
      klass.class_eval do
        private
        

        def create_or_update_with_authorized
#          (new_record? && create_authorized?) ||
#          (!new_record? && update_authorized?) ?
            create_or_update_without_authorized #:
#            fail("user is not authorized to save this record")
        end
        alias_method_chain :create_or_update, :authorized # had to be done due to error message about singleton method super for multiple classes not supported until 1.9.3 or later

# To turn versioning back on, uncomment #create and #update defs below, check to make sure create is being entered on create
#        def create(*)
#          self.transaction do
#            super
#            version.save!
#          end
#        end

#        def update(*)
#          self.transaction do
#            super
#            version.destroy
#            new_version.save
#          end
#        end
      end
    end
  end
end