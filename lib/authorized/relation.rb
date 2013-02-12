module Authorized
  module Relation

    def applied_scopes
      @applied_scopes ||= Set.new
    end

    def authorized passkey = nil
      passkey ? (@authorized ||= passkey) && self : @authorized
    end

    def find(*args)
      if ( ( self.klass.superclass != Record ) ||
        ( args[1] && args[1].delete(:bypass_auth) )
      )
        super(*args)
      elsif ( applied_scopes.include?(:authorize) )
        result = super(*args)
        if result.respond_to?(:each)
          result.collect{|item| item.authorize(authorized)}
        else
          result.authorize(authorized)
        end
      else
        super(*args) #FIXME temporary until full security can be turned on without hassle
#         fail("unlock this collection with the passkey first")
      end
    end

    def merge(r, association_name = nil)
      self.applied_scopes.merge(r.applied_scopes)
      self.authorized(r.authorized)
      super(r, association_name)
    end
  end
end
