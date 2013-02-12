class ActiveRecord::Base
  class << self
    def collection
      SyncCollection.new({type: self, collection: self })
    end
  end
end

class ActiveRecord::Relation
  def collection
    SyncCollection.new({type: klass, collection: self })
  end
end

class ActiveRecord::NamedScope::Scope
  def collection
    SyncCollection.new({type: proxy_scope, collection: self })
  end
end

class ActiveRecord::Associations::AssociationCollection
  def collection
    SyncCollection.new({type: @reflection.klass, collection: self })
  end
end
