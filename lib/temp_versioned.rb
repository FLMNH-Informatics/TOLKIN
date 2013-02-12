module TempVersioned
  def self.included(base)
    base.class_exec {
      scope :active,
        joins: 'INNER JOIN timelines ON (timelines.nid = timeline_nid) AND timelines.deleted_at is null',
        conditions: 'is_working_copy = false AND is_current = true',
        order: "#{table_name}.name ASC, #{table_name}.id DESC"

#      default_scope distinct: "#{table_name}.timeline_nid",
#        distinct_order: "#{table_name}.timeline_nid ASC, #{table_name}.updated_at DESC",
#        joins: "INNER JOIN timelines ON (timelines.nid = timeline_nid) AND timelines.deleted_at is null",
#        conditions: 'is_working_copy = false AND is_current = true',
#        order: "foo.name ASC, foo.id DESC"

      def self.destroy_all conditions = nil
        fail 'too bad - this method is not written yet'
        #update_all "deleted_at = now()", conditions
      end
    }
  end

# TAKEN CARE OF WITH TRIGGERS
#  def before_save
#    unless self.is_working_copy
#      if self.timeline.nil?
#        timeline = Timeline.create!
#        self.timeline_nid = timeline.nid
#      end
#    end
#  end

  def timeline
    Timeline.find(:first, conditions: { nid: self.timeline_nid })
  end

  def destroy!
    timeline=self.timeline
    timeline.deleted_at = Time.now
    timeline.save!
#    save!
  end

  def destroy
    timeline=self.timeline
    debugger if timeline.nil?
    timeline.deleted_at = Time.now
    timeline.save
#    save
  end

  def validate
    self.id.nil? # only allow save to occur if a new version has been created first
  end

#  def working! # create a working copy divorced from timeline - include in changeset instead
#    self.timeline = nil
#    self.is_working_copy = true
#  end
end
