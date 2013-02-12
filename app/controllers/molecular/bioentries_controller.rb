require 'bio'
require "net/http"
require "net/https"
require "erb"
require "singleton"
require "uri"
require 'uuidtools'
# require 'hpricot'

PANEL = 'www.ncbi.nlm.nih.gov'
PATH = '/WebSub/template.cgi'
USERAGENT = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100214 Ubuntu/9.10 (karmic) Firefox/3.5.8'
BOUNDARY = "62084521711919926317533026889"


class Molecular::BioentriesController < ApplicationController

  include Restful::Responder
  # index, show, new, edit, create, update, destroy, create_state, send_email
  before_filter :requires_project_guest,   :only => [ :index, :show ]
  before_filter :requires_selected_project

  def index
    params.include?(:order) || params[:order] = 'description'
    params.merge!({:limit => '20'})
    respond_to_index_request_searchlogic(@current_project.bioentries)
  end

  def show
    @bioentry = Molecular::Bioentry.find(params[:id], :include => :biosequence)
    debugger
    respond_to do |format|
      #format.js {render :partial => 'show', :collection => @bioentry}
      format.js { render :json => @bioentry.to_json(:include => :biosequence) }
      format.xml  { render :xml => @bioentry }
      format.html { render 'show', :layout => 'window' }
    end
  end

  def browse_fasta_file
    respond_to do |format|
      format.js { @window_name = :import_fasta_file; render "shared/bioentry_show_window" }
    end
  end

  #Save the id, sequence, organism information of the fasta file in the database
  def save_imported_fasta_to_db (id, organism, sequence)
    @project = Project.find(params[:project_id])
    Molecular::Bioentry.transaction do
      biodatabase = Molecular::Biodatabase.find_by_name('nucleotide') || Molecular::Biodatabase.create!(:name => 'nucleotide')
      @bioentry = Molecular::Bioentry.create!(:biodatabase => biodatabase,
        #:taxon_id => '',
        :name => '',
        #:accession => ,
        #:identifier => '',
        :division => '',
        :description => id + " : " + organism,
        :version => 1,
        :project => @project,
        :uuid => id,
        :user_id => Integer(session[:user_id]),
        :species_name => organism)
        debugger
      @biosequence = Molecular::Biosequence.create!(:bioentry => @bioentry,
        :version => 1,
        :length => sequence.length,
        :alphabet => 'dna',
        :seq => sequence)
      debugger

      @seqfeat = SequenceFeature.new()
      @seqfeat.start_loc = 1
      @seqfeat.end_loc = sequence.length
      @seqfeat.feature = 'gene'
      @seqfeat.qual = 'gene'
      #@seqfeat.value = params[:marker]
      @seqfeat.seq_id = id
      @seqfeat.save
    end
  end

  def import_from_genbank
    ids = params[:conditions].match(/^([\d,]+)\[id\]/)[1].split(',')
    xml = Bio::NCBI::REST::EFetch.sequence(ids, 'xml')
    document = Hpricot(xml)
    (document/'/INSDSet/INSDSeq').each do |seqNode|
      seq = INSD::Seq.create!(
        locus:              (seqNode/'/INSDSeq_locus').inner_html,
        length:             (seqNode/'/INSDSeq_length').inner_html,
        strandedness:       (seqNode/'/INSDSeq_strandedness').inner_html,
        moltype:            (seqNode/'/INSDSeq_moltype').inner_html,
        topology:           (seqNode/'/INSDSeq_topology').inner_html,
        division:           (seqNode/'/INSDSeq_division').inner_html,
        update_date:        (seqNode/'/INSDSeq_update-date').inner_html,
        create_date:        (seqNode/'/INSDSeq_create-date').inner_html,
        update_release:     (seqNode/'/INSDSeq_update-release').inner_html,
        create_release:     (seqNode/'/INSDSeq_create-release').inner_html,
        definition:         (seqNode/'/INSDSeq_definition').inner_html,
        primary_accession:  (seqNode/'/INSDSeq_primary-accession').inner_html,
        entry_version:      (seqNode/'/INSDSeq_entry-version').inner_html,
        accession_version:  (seqNode/'/INSDSeq_accession-version').inner_html,
        project:            (seqNode/'/INSDSeq_project').inner_html,
        segment:            (seqNode/'/INSDSeq_segment').inner_html,
        source:             (seqNode/'/INSDSeq_source').inner_html,
        organism:           (seqNode/'/INSDSeq_organism').inner_html,
        taxonomy:           (seqNode/'/INSDSeq_taxonomy').inner_html,
        comment:            (seqNode/'/INSDSeq_comment').inner_html,
        primary:            (seqNode/'/INSDSeq_primary').inner_html,
        source_db:          (seqNode/'/INSDSeq_source-db').inner_html,
        database_reference: (seqNode/'/INSDSeq_database-reference').inner_html,
        sequence:           (seqNode/'/INSDSeq_sequence').inner_html,
        contig:             (seqNode/'/INSDSeq_contig').inner_html
      )

    end
    debugger
    "hello"
  end

  def import_fasta_file
    debugger
#    file_name = "#{RAILS_ROOT}/public/files/FastaFile.fsa"
    file_name = params[:bioentry][:uploaded_data]
    sequence = ""
    seq_id = ""
    org_name = ""
    debugger
    @project = Project.find(params[:project_id])
    IO.foreach(file_name) {|x| 
      chk_seq_start = x.chomp.index('>')
      if !chk_seq_start.nil?
        if sequence != ""
          save_imported_fasta_to_db(seq_id, org_name, sequence)
        end
        temp_line = x.chomp.split(' ')
        seq_id = temp_line[0][Integer(chk_seq_start)+1, temp_line[0].length - 1]
        org_name_start = x.chomp.index('organism=') + 'organism='.length
        temp_line = x.chomp.split(']')
        org_name = temp_line[0][Integer(org_name_start), temp_line[0].length - 1]
        sequence = ""
        
      else
        sequence = sequence + x.chomp
      end
    }
    if sequence != ""
          save_imported_fasta_to_db(seq_id, org_name, sequence)
    end
    puts sequence
    flash[:notice] = "Imported successfully"
    respond_to do |format|
      format.js
    end
  end

  def new
    @version_number = 1
    @attributes = get_attributes

    respond_to do |format|
      format.js   {render :template => "shared/bioentry_show_window", :locals => {:window_name => 'new_bioentry_window'} }
      format.html # new.html.erb
      format.xml  { render :xml => @bioentry }
    end
  end

  #Genbank sequence submission changes - Open genabk sequence submission window
  def show_genbank_form
    @version_number = 1
    trunc_sequence = ''
    @attributes = get_attributes
    @userinfo = User.find_by_id(Integer(session[:user_id]))
    length = 1
    condition_arr = params[:conditions].split(',');
    session[:dnaseq] = nil
    dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
    condition_arr.each do |bioentry_id|
      dnafeats = DnaGenbankInfo::Seqfeaturecoll.new()
      if length == condition_arr.length
        bioentry_id = bioentry_id[0, bioentry_id.index('[')]
      end
      @bioentry_rel =  Molecular::Bioentry.find(Integer(bioentry_id))
      @biosequence = Molecular::Biosequence.find(Integer(bioentry_id))
      @seq_feature = SequenceFeature.find_all_by_seq_id(@bioentry_rel.uuid)
      @seq_feature.each do |dnafeat|
        feat =  DnaGenbankInfo::Seqfeature.new(dnafeat.feature, dnafeat.qual, dnafeat.value, dnafeat.start_loc, dnafeat.end_loc)
        dnafeats.add_seqfeatures(feat)
      end
      if @biosequence.seq.length > 20
        trunc_sequence = @biosequence.seq
        trunc_sequence = trunc_sequence[0..19] + "..."
      else
        trunc_sequence = @biosequence.seq
      end
      dnaseq = DnaGenbankInfo::Dnasequence.new(@bioentry_rel.uuid, @bioentry_rel.name, @biosequence.seq, '', trunc_sequence, length, dnafeats, @bioentry_rel.species_name)
      dnaseqs.add_sequences(dnaseq)
      length = length + 1
    end
    session[:dnaseq] = dnaseqs
    @dnasequences = dnaseqs
    respond_to do |format|
      format.js { @window_name = :export_to_genbank; @user = @userinfo; render "shared/bioentry_show_window", :collection => @dnasequences }
    end
  end

  #Save each sequence & feature inforamation when submit clicked on sequence window
  def save_dna_seq_info
    dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
    dnafeats = DnaGenbankInfo::Seqfeaturecoll.new()
    @project = Project.find(params[:project_id])
    uuid = UUIDTools::UUID.timestamp_create().to_s
    if(!params[:dnasequence][:feat_count].nil?)
      feat_count = Integer(params[:dnasequence][:feat_count])
      if !session[:dnaseq].nil?
        dnaseqs = session[:dnaseq]
      end
      if !dnaseqs.nil?
        count = dnaseqs.count + 1
      else
        count = 1
      end
      feat_count.times do |ctr|
        feat = params[:dnasequence]["seq_feat_key_#{(ctr+1).to_s}".to_sym]
        feat_array = feat.split('~');
        feat_key = feat_array[1];
        qual = params[:dnasequence]["seq_qual_key_#{(ctr+1).to_s}".to_sym]
        qual_array = qual.split('~');
        qual_key = qual_array[1];
        val_key = params[:dnasequence]["seq_val_key_#{(ctr+1).to_s}".to_sym]
        loc_start = params[:dnasequence]["feat_loc_start_#{(ctr+1).to_s}".to_sym]
        loc_end = params[:dnasequence]["feat_loc_end_#{(ctr+1).to_s}".to_sym]
        dnafeat =  DnaGenbankInfo::Seqfeature.new(feat_key, qual_key, val_key, loc_start, loc_end)
        dnafeats.add_seqfeatures(dnafeat)
      end
      if params[:dnasequence][:DNAseq].length > 20
        trunc_sequence = params[:dnasequence][:DNAseq]
        trunc_sequence = trunc_sequence[0..19] + "..."
      else
        trunc_sequence = params[:dnasequence][:DNAseq]
      end
      Molecular::Bioentry.transaction do
        biodatabase = Molecular::Biodatabase.find_by_name('nucleotide') || Molecular::Biodatabase.create!(:name => 'nucleotide')
        @bioentry = Molecular::Bioentry.create!(:biodatabase => biodatabase,
          #:taxon_id => '',
          :name => '',
          #:accession => ,
          #:identifier => '',
          :division => '',
          :description => params[:dnasequence][:DNAseqTitle],
          :version => 1,
          :project => @project,
          :uuid => uuid,
          :user_id => Integer(session[:user_id]),
          :species_name => params[:dnasequence][:DNAOrg_name])
        @biosequence = Molecular::Biosequence.create!(:bioentry => @bioentry,
          :version => 1,
          :length => params[:dnasequence][:DNAseq].length,
          :alphabet => 'dna',
          :seq => params[:dnasequence][:DNAseq])
        dnafeats.each do |dnafeat|
          @seqfeat = SequenceFeature.new()
          @seqfeat.start_loc = dnafeat.seq_feat_start_loc
          @seqfeat.end_loc = dnafeat.seq_feat_end_loc
          @seqfeat.feature = dnafeat.seq_feature
          @seqfeat.qual = dnafeat.seq_feat_qualifier
          @seqfeat.value = dnafeat.seq_feat_qual_value
          @seqfeat.seq_id = uuid
          @seqfeat.save
        end
      end
      dnaseq = DnaGenbankInfo::Dnasequence.new(uuid, params[:dnasequence][:DNAseqTitle], params[:dnasequence][:DNAseq], params[:dnasequence][:DNAseqStrain], trunc_sequence, count, dnafeats, params[:dnasequence][:DNAOrg_name])
      dnaseqs.add_sequences(dnaseq)
      session[:dnaseq] = dnaseqs
      if !session[:dnaseq].nil?
          @dnasequences = DnaGenbankInfo::Dnasequencecoll.new()
          @dnasequences = session[:dnaseq]
      end
      respond_to do |format|
        format.js
      end
    else
      flash[:error] = "Please add features for the sequence"
    end
#        show_genbank_form
  end


  #validate the form on submission of batch sequences.
  def validate_genbank_data
    if params[:bioentry][:submit_title].blank?
      return "Citation title"
    end
    if params[:bioentry][:contact_lname].blank?
      return "Last name"
    end
    if params[:bioentry][:contact_fname].blank?
      return "First name"
    end
    if params[:bioentry][:contact_inst].blank? && params[:bioentry][:contact_dept].blank? && params[:bioentry][:contact_city].blank? && params[:bioentry][:contact_state].blank? && params[:bioentry][:contact_ctry].blank? && params[:bioentry][:contact_st].blank? && params[:bioentry][:contact_zip].blank?
      return "Affiliation"
    end
    if params[:bioentry][:contact_email].blank?
      return "Email id"
    end
    if params[:bioentry][:contact_phone].blank?
      return "Phone"
    end
    if params[:bioentry][:contact_zip].blank?
      return "Zipcode"
    end
    if params[:bioentry][:contact_ctry].blank?
        return "Country"
    end
    if params[:bioentry][:contact_state].blank?
      return "State"
    end
    if params[:bioentry][:contact_fax].blank?
      return "Fax"
    end
    if !session[:dnaseq].nil?
      dnaseqs = session[:dnaseq]
    end
    if !dnaseqs.nil?
      dnaseqs.each do |dnaseq|
        if dnaseq.seq_id.nil?
          return "Dna sequence id"
        end
        if dnaseq.seq_title.nil?
          return "Dna sequence title"
        end
        if dnaseq.sequence.nil?
          return "Dna sequence"
        end
        seqfeats = dnaseq.seq_features
        if !seqfeats.nil?
          seqfeats.each do |seqfeat|
            if seqfeat.seq_feat_start_loc.blank?
              return "Start location of " + dnaseq.seq_title
            end
            if seqfeat.seq_feat_end_loc.blank?
              return "End location of " + dnaseq.seq_title
            end
          end
        else
          return "Feature information for " + dnaseq.seq_title
        end

      end
    else
      return "Dna sequences"
    end
    return nil
  end

  #Create the features table file used as an input to tbl2asn
  def create_features_file
    File.open("#{RAILS_ROOT}/public/files/FastaFile.tbl", "w") do |ex_file|
        dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
        if !session[:dnaseq].nil?
          dnaseqs = session[:dnaseq]
        end
        dnaseqs.each do |dnaseq|
          ex_file.write (">Features " + dnaseq.seq_id.to_s + "\n")
          strfeat = ""
          seqfeats = dnaseq.seq_features
          seqfeats.each do |seqfeat|
            if strfeat != seqfeat.seq_feature
              ex_file.write (seqfeat.seq_feat_start_loc + "\t" + seqfeat.seq_feat_end_loc + "\t" + seqfeat.seq_feature + "\n")
            end
            if !seqfeat.seq_feat_qual_value.nil?
              ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier + "\t" + seqfeat.seq_feat_qual_value + "\n")
            else
              ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier  + "\n")
            end
            strfeat = seqfeat.seq_feature
          end
        end
      ex_file.close
    end
  end

  #Create the fasta sequence file used as an input to tbl2asn
  def create_fasta_files
    File.open("#{RAILS_ROOT}/public/files/FastaFile.fsa", "w") do |ex_file|
        dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
        if !session[:dnaseq].nil?
          dnaseqs = session[:dnaseq]
        end
        dnaseqs.each do |dnaseq|

          if !dnaseq.seq_id.nil?
            ex_file.write (">" + dnaseq.seq_id.to_s + " [organism=" + dnaseq.organism_name + "] [strain=" + dnaseq.seq_strain.to_s + "] \n")
            ex_file.write (dnaseq.sequence + "\n")
          end
        end
      ex_file.close
    end
  end

  #called when form is finally submitted
  def export_to_genbank
    # Validate the inputs
    rtnvalidate = validate_genbank_data
    str = ""
    if !rtnvalidate.nil?
      str = rtnvalidate + " is compulsary."
      flash[:error] = str
    else
      # Create the fasta file for the DNA sequence
      create_fasta_files
      create_features_file
      uri = URI.parse("http://www.ncbi.nlm.nih.gov/WebSub/template.cgi")
      #------------------------------------------------------------------------
      post_body = []
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"first_name\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_fname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"last_name\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_lname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"department\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_dept]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"institution\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_inst]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"street\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_st]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"city\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_city]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"state\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_state]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"zip\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_zip]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"country\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_ctry]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"phone\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_phone]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"fax\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_fax]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"email\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_email]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_first_1\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_fname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_mi_1\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_mname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_last_1\"\r\n\r\n"
      post_body << "#{params[:bioentry][:contact_lname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_suffix_1\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_first_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_mi_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_last_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_suffix_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_status_radio\"\r\n\r\n"
      post_body << "unpublished\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"citation_title\"\r\n\r\n"
      post_body << "#{params[:bioentry][:submit_title]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_title\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_yr\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_vol\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_issue\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_pages_from\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"jrnl_pages_to\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_pmid\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_auth_radio\"\r\n\r\n"
      post_body << "same\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_first_1\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_mi_1\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_last_1\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_suffix_1\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_first_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_mi_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_last_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"cit_author_suffix_\"\r\n\r\n"
      post_body << "\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"submit\"\r\n\r\n"
      post_body << "Create Template\r\n"
      post_body << "--#{BOUNDARY}--\r\n"
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path)
      request.body = post_body.join
      request["Host"] = "www.ncbi.nlm.nih.gov"
      request["User-Agent"] = USERAGENT
      request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      request["Accept-Language"] = "en-us,en;q=0.5"
      #request["Accept-Encoding"] = "gzip,deflate"
      request["Accept-Charset"] = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      request["Keep-Alive"] = "300"
      request["Connection"] = "keep-alive"
      request["Referer"] = "http://www.ncbi.nlm.nih.gov/WebSub/template.cgi"
      request["Content-Type"] = "multipart/form-data; boundary=#{BOUNDARY}"
      request["Content-Length"] = post_body.join.size.to_s
      resp, data = http.request(request)

      resp.each {|key, val| puts key + ' = ' + val}
      puts data
      File.open("#{RAILS_ROOT}/public/files/template.sbt", "w") do |ex_file|
        ex_file.write resp.body
        ex_file.close
      end

      #
      if !params[:bioentry][:rel].nil?
        release_date = params[:bioentry][:"publish_date(2i)"].to_s + "/" + params[:bioentry][:"publish_date(3i)"].to_s + "/" + params[:bioentry][:"publish_date(1i)"]
        `#{RAILS_ROOT}/public/files/./tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s -H '#{release_date}'`
      else
        `#{RAILS_ROOT}/public/files/./tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s`
      end

      #Send mail to genbank
      mail = IssueMailer.create_sendmail(params[:bioentry][:contact_email], params[:bioentry][:submit_title])
      IssueMailer.deliver(mail)
      #save_sequence_feature_records
      
      flash[:notice] = 'Sequence submission was successfully sent.'
      session[:dnaseq] = nil
      debugger
      respond_to do |format|
        format.html { redirect_to(project_bioentries_path(params[:project_id])) }
        format.js
      end
    end
  end
  #Genbank sequence submission changes - END

  def create
    @project = Project.find(params[:project_id])
    #taxon = Taxa.find_by_name('taxon_name')
    seq_uuid = UUIDTools::UUID.timestamp_create().to_s
    Molecular::Bioentry.transaction do
      biodatabase = Molecular::Biodatabase.find_by_name('nucleotide') || Molecular::Biodatabase.create!(:name => 'nucleotide')
      @bioentry = Molecular::Bioentry.create!(:biodatabase => biodatabase,
        :name => params[:bioentry][:name],
        #:accession => ,
        #:identifier => '',
        :division => '',
        :description => params[:bioentry][:description],
        :version => 1,
        :project => @project,
        :uuid => seq_uuid,
        :user_id => Integer(session[:user_id]),
        :species_name => params[:bioentry][:org_name])

      @biosequence = Molecular::Biosequence.create!(:bioentry => @bioentry,
        :version => 1,
        :length => params[:bioentry][:seq].length,
        :alphabet => 'dna',
        :seq => params[:bioentry][:seq])

      if(!params[:dnasequence][:feat_count].nil?)
        feat_count = Integer(params[:dnasequence][:feat_count])
        feat_count.times do |ctr|
          feat = params[:dnasequence]["seq_feat_key_#{(ctr+1).to_s}".to_sym]
          feat_array = feat.split('~')
          feat_key = feat_array[1]
          qual = params[:dnasequence]["seq_qual_key_#{(ctr+1).to_s}".to_sym]
          qual_array = qual.split('~')
          qual_key = qual_array[1]
          val_key = params[:dnasequence]["seq_val_key_#{(ctr+1).to_s}".to_sym]
          loc_start = params[:dnasequence]["feat_loc_start_#{(ctr+1).to_s}".to_sym]
          loc_end = params[:dnasequence]["feat_loc_end_#{(ctr+1).to_s}".to_sym]

          @seqfeat = SequenceFeature.new()
          @seqfeat.start_loc = loc_start
          @seqfeat.end_loc = loc_end
          @seqfeat.feature = feat_key
          @seqfeat.qual = qual_key
          @seqfeat.value = val_key
          @seqfeat.seq_id = seq_uuid
          @seqfeat.save
        end
      end
      
      flash[:notice] = 'New sequence was successfully added.'
    end
    if params[:search]
      @bioentries = @project.bioentries.search(@search_terms).paginate( :page => params[:page] )
    else
      @bioentries = @project.bioentries.all.paginate( :page => params[:page], :per_page => 20, :order=>"bioentry.bioentry_id")
    end
    respond_to do |format|
      format.js
    end
  end

  def destroy_all
    success =false
    condition_arr = params[:conditions].split(',');
    length = 1
    condition_arr.each do |bioentry_id|
      if length == condition_arr.length
        bioentry_id = bioentry_id[0, bioentry_id.index('[')]
      end
      @bioentry =  Molecular::Bioentry.find(Integer(bioentry_id))
      @biosequence = Molecular::Biosequence.find(Integer(bioentry_id))
      @seq_feature = SequenceFeature.find_by_seq_id(@bioentry.uuid)
       Molecular::Bioentry.transaction do
         if !@seq_feature.nil?
          success = @seq_feature.destroy
         end
         if !@biosequence.nil?
          success = @biosequence.destroy
         end
         success = @bioentry.destroy
         if success.nil?
           break
         end
       end
      length = length + 1
    end
    if success.nil?
      flash[:error] = "Sequences could not be deleted successfully"
    else
      flash[:notice] = "Sequences deleted successfully"
    end
    respond_to do |format|
      format.js
    end

  end

  def get_attributes
    @@attributes ||= [ { :name => :tolkin_id, :label => "Tolkin ID", :edit_type => 'standard' },
      #{ :name => :taxon, :label => "Taxon", :edit_type => 'standard' },
      { :name => :genbank_id, :label => "Genbank ID", :edit_type => 'standard' },
      { :name => :description, :label => "Description", :edit_type => 'standard' },
      { :name => :version, :label => "Version", :edit_type => 'standard' } ]
  end

  def align
    atts = params[:ids].match(/[0-9,]*/)[0]
    ids = atts.split(',')
    seqs = Array.new
    ids.each do |id|
      seqs << Insd::Seq.find(id).sequence
    end

    a = Bio::Alignment.new(seqs)
    a.consensus
    a.consensus_iupac()
    a.each{|x| p x}
    a.each_site{|x| p x}
    
    opts = Array.new
    params[:align].each{ |key,value| opts << "-#{key}=#{value}" }
    factory = Bio::ClustalW.new('clustalw', opts)
    #debugger
    aligned = a.do_align(factory)
    debugger
    align = Molecular::Alignment.create(:name => params[:title], :description => params[:description], :seq => aligned.to_fasta)

    redirect_to project_molecular_alignments_path(align.id)
    #puts aligned.output('clustal')
  end
  
end

  #Save/update the batch submission related information in the Tolkin database
#  def save_sequence_feature_records
#    dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
#    if !session[:dnaseq].nil?
#      dnaseqs = session[:dnaseq]
#    end
#      dnaseqs.each do |dnaseq|
#        @seq_record = GenbankSequenceSubmissionRecord.find_by_uuid(dnaseq.seq_id)
#        @seq_record.update_attribute(:submission_title, params[:bioentry][:submit_title])
#        @seq_record.update_attribute(:organism_name, params[:bioentry][:org_name])
#        @seq_record.update_attribute(:organism_location, params[:bioentry][:org_loc])
#        @seq_record.update_attribute(:updation_time, Time.now())
#          seqfeats = dnaseq.seq_features
#          seqfeats.each do |seqfeat|
#            @seqfeat = SequenceFeature.new()
#            @seqfeat.start_loc = seqfeat.seq_feat_start_loc
#            @seqfeat.end_loc = seqfeat.seq_feat_end_loc
#            @seqfeat.feature = seqfeat.seq_feature
#            @seqfeat.qual = seqfeat.seq_feat_qualifier
#            @seqfeat.value = seqfeat.seq_feat_qual_value
#            @seqfeat.seq_id = dnaseq.seq_id
#
#            if @seqfeat.save
#              puts 'Feature ' + @seqfeat.feature + '-' + @seqfeat.qual + '-' + @seqfeat.value + ' entered'
#            else
#              puts 'Failed to enter'
##              flash[:notice] = 'Feature could not be saved successfully.'
##              session[:dnaseq] = nil
##              respond_to do |format|
##          #      #format.html { redirect_to(project_bioentries_path(params[:project_id])) }
##                format.js
##              end
#            end
#          end
#
#    end
#  end

