module ActiveRecord
  class Base
    include SyncRecords::AssociationPreload
  end
end