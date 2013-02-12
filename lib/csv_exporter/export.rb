# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'csv'

class CsvExporter::Export
  def initialize
    
  end
# Pass the recs is databaserecords   column_names is array that contais names of columns
  def self.export_to_csv recs , column_names
#    @recs = [];
#	if column_names.nil? || column_names.length == 0
#		@recs = model.find(:all)
#	else
#		@recs = model.find(:all , :select => (column_names))
#	end

	  csv_string = CSV.generate do |csv|
	    # header row
	    csv << column_names

      # data rows
      recs.each do |rec|
        csv <<  column_names.inject([]) do |out, col|
             #hack for taxon export on collection
             if col.include?('taxon_id')
               out.push(rec.send(col.gsub('_id','')).try(:name))
             else
               out.push(rec[col])
             end
        end
        
      end
    end



  end
end
