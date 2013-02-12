class VsattrsObserver < ActiveRecord::Observer

  def before_create record
    record.creator_rtid = record.authorized.rtid
    record.created_at = Time.now
  end

  def before_update record
    record.deleter_rtid = record.authorized.rtid
    record.deleted_at   = Time.now
  end
end