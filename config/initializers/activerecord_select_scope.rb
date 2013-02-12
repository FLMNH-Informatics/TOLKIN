module ActiveRecord
  class Base
    include SyncRecords::SelectScope
  end
end