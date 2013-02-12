#TODO this is not an elegant solution but the gem wanted a class with errors to add to like the active record objects. either considering creating a model for this or try using a different recaptcha ruby plugin http://svn.ambethia.com/pub/rails/plugins/recaptcha/ which doesnt seem to ask for the active record object or change the gem class which we donot wish to do.
module MySessionModule
  class NewSessionErrors
    def initialize
          @errors = Array.new      
    end
    def add_to_base(msg)
      @errors << msg
    end
  end
end