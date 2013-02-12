class Version

  attr_reader :record

  delegate :authorized, to: :record

  def initialize options
    @record = options[:record]
    @attributes = options[:attributes]
  end

  def clone
    Version.new(
      record: record, 
      attributes: attributes.reject{|k,v| record.vsattrs.attribute_names.include?(k.to_s) }
    )
  end

  def attributes
    @attributes ||= @record.vsattrs.attributes.merge(@record.vtattrs.attributes)
  end

  def save
    @record.transaction do
      vsattrs =
        @record.class::Vsattrs.create!(
          rtid: record.rtid,
          creator_rtid: authorized.user.rtid,
          created_at: Time.now
        )
      @record.class::Vtattrs.create!(
        @attributes.merge({
          vtid: vsattrs.vtid,
        })
      )
    end
  end

  def destroy
    @record.vsattrs.update_attributes!({
      deleter_rtid: authorized.user.rtid,
      deleted_at: Time.now
    })
  end

#  def create! params, current_user
#    ::Vsattrs.find(@record.vtid).update_attributes!({})
#    new_vsattrs = ::Vsattrs.create!(rtid: @record.rtid)
#    @record.klass::Vtattrs.create!(
#      params.merge(vtid: new_vsattrs.vtid)
#    )
#    debugger
#    "hello"
#    fail('didnt make it')
#  end
end