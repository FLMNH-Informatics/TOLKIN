module DataCache

  properties_to_load = [ 'rdfs:member' ]
  
  @cache = { rtids: { properties: {} } }

  @connection = ActiveRecord::Base.connection
  @connection.select_rows(%{
    SELECT vt.label, vs.rtid
    FROM vsattrs vs
    INNER JOIN property_vtattrs vt ON (vt.vtid = vs.vtid AND vt.label IN (#{properties_to_load.collect{|i|"'#{i}'"}.join(',')}))
    WHERE vs.deleted_at IS NULL
  }).each do |result|
    @cache[:rtids][:properties][result[0]] = result[1].to_i
  end


  def self.rtids
    @cache[:rtids]
  end
end