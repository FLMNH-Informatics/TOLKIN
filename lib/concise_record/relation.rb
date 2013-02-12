module ConciseRecord
  module Relation
    def construct_relation_for_association_find(join_dependency)
      relation = except(:includes, :eager_load, :preload) # THIS LINE MODIFIED - DONT USE ALTERNATE SELECT CONDS
      apply_join_dependency(relation, join_dependency)
    end
  end
end