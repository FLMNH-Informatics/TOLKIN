# abstract class
class Record < ActiveRecord::Base
  
#  include SyncRecords::Mixins::ToJson

  attr_accessor :new_version

  has_many :in_statements, :class_name => 'Statement', :primary_key => :rtid, :foreign_key => :obj_rtid
  has_many :out_statements, :class_name => 'Statement', :primary_key => :rtid, :foreign_key => :subj_rtid

  

  has_one :rsattrs, :primary_key => :rtid, :foreign_key => :rtid

  def version
    @version ||= Version.new(record: self)
  end

  def self.inherited(subclass)
    super

    subclass.const_set("Vtattrs", Class.new(::Vtattrs) do
      self.primary_key = 'vtid'
      self.table_name = "#{subclass.to_s.underscore}_vtattrs"
    end)

    subclass.const_set("Vsattrs", Class.new(::Vsattrs) do
      has_one :vtattrs, :primary_key => :vtid, :foreign_key => :vtid
    end)

    subclass.class_eval do
      include Authorized::Base
      belongs_to :permission_set, primary_key: :permission_set_rtid,       foreign_key: :owner_permission_set_rtid
      has_many   :record_permissions, class_name: 'Permission', primary_key: :owner_permission_set_rtid, foreign_key: :permission_set_rtid

      class << self
        attr_accessor :auto_complete_text_method
        
        def base_class
          self
        end
      end

      self.table_name = subclass.to_s.underscore.pluralize
      self.primary_key = "#{subclass.to_s.underscore}_id"

      has_one  :vsattrs, :primary_key => :rtid, :foreign_key => :rtid, :conditions => { :deleted_at => nil }
      delegate :vtattrs, :to => :vsattrs
    end
  end
end
