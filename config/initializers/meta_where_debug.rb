#module MetaWhere
#  module JoinDependency
#    def build_with_metawhere(associations, parent = nil, join_type = Arel::Nodes::InnerJoin)
#      parent ||= @joins.last
#      if MetaWhere::JoinType === associations
#        klass = associations.klass
#        join_type = associations.join_type
#        associations = associations.name
#      end
#
#      case associations
#      when Symbol, String
#        reflection = parent.reflections[associations.to_s.intern] or
#          debugger or
#          raise ConfigurationError, "Association named '#{ associations }' was not found; perhaps you misspelled it?"
#        unless (association = find_join_association(reflection, parent)) && (!klass || association.active_record == klass)
#          @reflections << reflection
#          if reflection.options[:polymorphic]
#            raise ArgumentError, "You can't create a polymorphic belongs_to join without specifying the polymorphic class!" unless klass
#            association = PolymorphicJoinAssociation.new(reflection, self, klass, parent)
#          else
#            association = build_join_association(reflection, parent)
#          end
#          association.join_type = join_type
#          @joins << association
#          cache_joined_association(association)
#        end
#        association
#      else
#        build_without_metawhere(associations, parent, join_type)
#      end
#    end
#  end
#end