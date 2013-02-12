# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'bio'

class Molecular::Resources::Ncbi::EUtils::EFetch
  def self.from_xml xml_string
    #Create an Object for storing the XML element data
    @sequence = GenbankSequenceSubmissionRecord.new()
    count_id = 0
    document = Hpricot(xml_string)
    fail "problem communicating with NCBI" unless document.at('/GBSet/ERROR').nil?
    @sequence.sequence_title = document.at('/GBSet/GBSeq/GBSeq_definition').inner_html
    @sequence.organism_name = document.at('/GBSet/GBSeq/GBSeq_organism').inner_html
    @sequence.creation_time = document.at('/GBSet/GBSeq/GBSeq_create-date').inner_html
    @sequence.updation_time = document.at('/GBSet/GBSeq/GBSeq_update-date').inner_html
    @sequence.sequence = document.at('/GBSet/GBSeq/GBSeq_sequence').inner_html
    @sequence.uuid = document.at('/GBSet/GBSeq/GBSeq_locus').inner_html

    (document/'/GBSet/GBSeq/GBSeq_other-seqids/GBSeqid').each do |id_node|
      count_id+=1
      # The 2nd tag contains the Genbank ID, teh 1st tag contains the accession number
      id_array = id_node.inner_html.split('|')
      if(count_id == 2)
        @sequence.genbank_id =  id_array[1]
      end
    end
     #Save the sequence first
    @sequence.save

    (document/'/GBSet/GBSeq/GBSeq_feature-table/GBFeature').each do |id_node|
      (id_node/'/GBFeature_quals/GBQualifier').each do |qual_node|
        @seqfeat = SequenceFeature.new()
        @seqfeat.start_loc = (id_node/'/GBFeature_intervals/GBInterval/GBInterval_from').inner_html
        @seqfeat.end_loc = (id_node/'/GBFeature_intervals/GBInterval/GBInterval_to').inner_html
        @seqfeat.feature = (id_node/'/GBFeature_key').inner_html
        @seqfeat.qual = (qual_node/'/GBQualifier_name').inner_html
        @seqfeat.value = (qual_node/'/GBQualifier_value').inner_html
        @seqfeat.seq_id = document.at('/GBSet/GBSeq/GBSeq_locus').inner_html
        #Save all the features of the sequence then
        @seqfeat.save
      end
    end
    { :sequence => @sequence, :seqfeature => @seqfeat }
  end

  def self.from_text text_string
    text_string.chomp("\n//\n\n").split('//').collect{ |record| Bio::GenBank.new(record) }
  end
end
