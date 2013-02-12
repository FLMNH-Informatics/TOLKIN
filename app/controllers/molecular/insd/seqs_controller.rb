#PANEL = 'www.ncbi.nlm.nih.gov'
#PATH = '/WebSub/template.cgi'
#USERAGENT = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.8) Gecko/20100214 Ubuntu/9.10 (karmic) Firefox/3.5.8'
#BOUNDARY = "62084521711919926317533026889"


class Molecular::Insd::SeqsController < ApplicationController
  include Restful::Responder
  include TolkinExporter
  include SeqSearch::MolMatrixGenbankSearch
  include Rack::Utils
  # index, show, new, edit, create, update, destroy, create_state, send_email
  before_filter :requires_project_guest,   :only => [ :index, :show ]
  before_filter :requires_selected_project

  def index
    query_params_provided? ||
      params.merge!(
      select: [ :pk, :markers_fulltext, :organism, :locus, :definition, :sequence ],
      order: [ :organism ],
      limit: 20
    )
    super(current_project.seqs)
  end

  def update
    @seq = Molecular::Insd::Seq.find(params[:id])
    params[:seq][:sequence] = params.delete(:SEQ).delete(:SEQUENCE)
    taxon = passkey.unlock(Taxon).where('name = ?', params[:molecular_insd_seq][:taxon_name]).first
    unless taxon.nil?
      params[:seq][:taxon_id] = taxon.taxon_id.to_s
      params[:seq][:organism] = taxon.name
      dates, ymd = ['create_date', 'update_date', 'create_release', 'update_release'],['mm', 'dd', 'Y']
      seq_dates  = dates.inject({}) do |memo, datetype|
        memo[datetype] = params[:seq].delete([*datetype].product(ymd)[0].join('_')) + '-' +
                         params[:seq].delete([*datetype].product(ymd)[1].join('_')) + '-' +
                         params[:seq].delete([*datetype].product(ymd)[2].join('_'))
        if memo[datetype] == '--' then memo[datetype] = '' end
        memo
      end
      params[:seq].merge!(seq_dates)
      @seq.update_attributes!(params[:seq])
      newmarkersarray = params[:seq_marker].values.transpose.map{|a| Hash[params[:seq_marker].keys.zip(a)]} unless params[:seq_marker].nil?
      oldmarkersarray = params[:mol_marker].values.transpose.map{|a| Hash[params[:mol_marker].keys.zip(a)]} unless params[:mol_marker].nil?
      if newmarkersarray
        newmarkersarray.each { |marker|
                  @seq.seq_markers.create!(:marker => current_project.markers.create!(marker.reject{|k,v| k == 'position' } ),
                                           :position => marker['position']) }
      end
      if oldmarkersarray
        oldmarkersarray.each { |marker| marker["marker_id"] = marker.delete('id') }
        oldmarkersarray.each { |marker| @seq.seq_markers.create!(marker) }
      end
      if @seq.save
        respond_to{|format| format.json { render :json => @seq}}
      else
        respond_to{|format| format.json {render :json => { :errormsg => "Error: Couldn't save.' "}}}
      end
    else
      respond_to {|format| format.json { render :json => { :errormsg => "There is no taxon with that name. " } } }
    end

  end

  def show
    @seq = current_project.sequences.find(params[:id])
    @taxon = @seq.taxon
    respond_to do |format|
      format.html { render 'show', layout: request.xhr? ? false : true }
      format.xml  { render :xml  => @seq }
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
      @seq = Molecular::Bioentry.create!(:biodatabase => biodatabase,
        #:taxon_id => '',
        :name => '',
        #:accession => ,
        #:identifier => '',
        :division => '',
        :description => id + " : " + organism,
        :version => 1,
        :project => @project,
        :uuid => id,
        :user_id => session[:user_id].to_i,
        :species_name => organism)
      debugger
      @biosequence = Molecular::Biosequence.create!(:bioentry => @seq,
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

  def render_alignment_seqs
    @seqs = Molecular::Insd::Seq.where(:pk => JSON.parse(params[:ids]).map{ |id| Integer(id) })
    html_to_render = render_to_string(:partial => 'alignment_seqs')
    respond_to{ |format| format.json { render :json => { :html_to_render =>  html_to_render.to_s } } }
  end

  def show_create_alignment
    if params[:conditions]
      parser = Restful::Parser.new
      @seqs = current_project.seqs.where(parser.parse(params, :conditions))
      html_to_render = render_to_string(:partial => 'alignment_seqs')
      respond_to { |format| format.json { render :json => { :html_to_render => html_to_render.to_s } }}
    elsif params[:cell_ids]
      cells = Molecular::Matrix::Cell.find(params[:cell_ids].split(','))
      @seqs = Molecular::Insd::Seq.where(:pk => cells.map{|cell| cell.force_primary_sequence.pk }.compact )
      html_to_render = render_to_string(:partial => 'alignment_seqs')
      respond_to { |format| format.json { render :json => { :html_to_render => html_to_render.to_s, :seq_ids => @seqs.collect{|seq| seq.id} } }}
    else
      respond_to { |format| format.html {render 'show_create_alignment', layout: request.xhr? ? false : 'application' } }
    end
  end

  def create_alignment
    @alignment = Molecular::Alignment.create!(params[:alignment])
    if params['matrix_id']
      @alignment.timeline_id = params['matrix_id']
    end
    @seqs = Molecular::Insd::Seq.where(:pk => params[:seqs])
    @seqs.each{ |seq| @alignment.alignment_seqs.create!(:seq_id => seq.pk) }
    @alignment.save
    @alignment.reload
    respond_to { |format| format.json { render :json => { :alignment => @alignment.to_json } } }
  end

  def seq_ids_from_markers_and_otus
    #@matrix = Matrix::UserMatrix.for_address_and_user_and_project(Matrix::Address.from_s(params[:matrix_id]), current_user, current_project)
    @matrix = Molecular::Matrix::Timeline.find(params[:matrix_id])
    marker_ids = params[:marker_ids].split(',')
    cell_seqs = []
    case params[:export_type]
      when "export_union"
        @matrix.cells.includes(:sequences, :primary_sequence).where(:otu_id => params[:otu_ids].split(',')).each do |cell|
          unless cell.nil?
            cell_seqs.push(cell.force_primary_sequence.id) unless cell.force_primary_sequence.nil?
            marker_ids.delete(cell.marker_id.to_s)
          end
        end
        @matrix.cells.includes(:sequences, :primary_sequence).where(:marker_id => marker_ids).each do |cell|
          cell_seqs.push(cell.force_primary_sequence.id) unless cell.force_primary_sequence.nil?
        end
      when params[:export_type] == "export_intersection"
        params[:otu_ids].split(',').each do |otu_id|66
          marker_ids.each do |marker_id|
            seq = Molecular::Insd::Seq.from_matrix_and_marker_and_otu(@matrix, marker_id, otu_id)
            cell_seqs.push(seq.id) unless seq.nil?
          end
        end
      end
    if cell_seqs.compact.empty?
      respond_to {|format| format.json { render :json => { :msg => 'No sequences for selected combination.'} } }
    else
      respond_to {|format| format.json { render :json => { :seq_ids => cell_seqs.compact.join(',') } } }
    end
  end

  def export
    seqs = params[:ids].split(',').collect{ |id| Molecular::Insd::Seq.find(id) }
    do_export(seqs)
  end

  def export_from_cells
    cells = Molecular::Matrix::Cell.includes(:sequences, :primary_sequence).find(params[:ids].split(','))
    seqs = cells.collect{ |cell| cell.force_primary_sequence }.compact
    do_export(seqs)
  end

  def export_from_seqs
    params[:conditions] = params[:ids]
    parser = Restful::Parser.new
    seqs = current_project.seqs.where(parser.parse(params, :conditions))
    do_export(seqs)
  end

  def do_export_ids
    seq_ids = params[:seq_ids].split(',')
    seqs = []
    seq_ids.each {|id| seqs.push(Molecular::Insd::Seq.find(id)) }
    output = seqs.collect{ |seq| seq.to_fasta }.join('')
    fpath = "#{RAILS_ROOT}/public/files/fasta.fasta"
    File.open(fpath, 'w'){ |f| f.write(output) }
    send_file(fpath, :disposition => 'attachment')
  end

  def do_export(seqs)
    output = seqs.collect{ |seq| seq.to_fasta }.join('')
    fpath  = "#{RAILS_ROOT}/public/files/" + current_user.user_id.to_s + "fasta.fasta"
    File.open(fpath, 'w'){ |f| f.write(output) }
    respond_to { |format| format.json {render :json => {:fpath => "/public" + fpath.split('/public').last } } }
  end

  def get_fasta
    send_file("#{RAILS_ROOT}/" + params[:fpath], :disposition => "attachment")
  end

  def search_nucleotide
    options = {"term" => params["term"]}
    @start, @limit, @columns = Integer(params["retstart"]), Integer(params["retmax"]), params['columns']
    if params["webenv"] = ''
      results = Molecular::Resources::Ncbi::EUtils.esearch( options.merge( { "retstart" => params["retstart"], "retmax" => params["retmax"] } ) )
      if results[:count]
        @webenv, @querykey, @count = results[:webenv], results[:querykey], Integer(results[:count])
        if results[:method]
          gb_records  = (results[:method] == 'ids') ?
            Molecular::Resources::Ncbi::EUtils.efetch_ids(results[:ids]) :
            Molecular::Resources::Ncbi::EUtils.efetch(@webenv, @querykey, params["retstart"], params["retmax"])
          display_genbank_results(gb_records)
        else
          respond_to {|format| format.json { render :json => { :errormsg => results[:errormsg] } } }
        end
      else
        respond_to {|format| format.json { render :json => { :errormsg => results[:errormsg] } } }
      end
    else
      @webenv, @querykey, @count = params["webenv"], params["querykey"], Integer(params["count"])
      summaries = Molecular::Resources::Ncbi::EUtils.efetch(@webenv, @querykey, params["retstart"], params["retmax"])
      display_genbank_results(summaries)
    end
  end

  def display_genbank_results summaries
    table, seqs = make_table(summaries)
    if seqs
      respond_to do |format|
        format.json { render :json => {:table_header => table_header, :table => table, :seqs => seqs, :count => @count, :history => {:webenv => @webenv, :querykey => @querykey} } }
      end
    else
      respond_to {|format| format.json { render :json => {:errormsg => table } } }
    end
  end



  def import_from_genbank
    ids = params[:conditions].match(/^([\d,]+)\[id\]/)[1].split(',')
    importer = GenbankImporter.new
    importer.import(ids)

    head :ok
  end

  def show_add_genbank_markers
    respond_to do |format|
      format.html { render 'show_add_genbank_markers', layout: request.xhr? ? false : 'application' }
    end
  end

  def show_upload_seqs
      respond_to {|format| format.html { render 'show_upload_seqs', layout: request.xhr? ? false : 'application' } }
  end

  def import_seqs
    uploaded_data = params[:seq][:uploaded_data].read
    fastas = uploaded_data.split('>')
    #fastafile = { :project_id => current_project.project_id,
    #              :filename => uploaded_data.original_filename,
    #              :content_type => uploaded_data.content_type }
    return 'hi'
  end

  def import_fasta_file
    debugger
#    file_name = "#{RAILS_ROOT}/public/files/FastaFile.fsa"
    file_name = params[:seq][:uploaded_data]
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

  def fasta_seqs_control
    respond_to { |format| format.html { render :partial => 'fasta_seqs_paging', layout: request.xhr? ? false : true } }
  end

  def new_sequence_marker_select
    respond_to { |format| format.html { render :partial => 'marker_concat_select', layout: request.xhr? ? false : true } }
  end

  def  create_marker
    @marker = Molecular::Marker.where('project_id = ? and lower_name = ?', params['project_id'], params['marker'].downcase).first || current_project.markers.new({:name => params[:marker]})
    if @marker.new_record?
      if @marker.save
        respond_to do |format|
          format.json { render :json => {:msg => %(Saved #{params['marker']} to this project) } }
          format.html { redirect_to(:back)  }
         end
      else
        respond_to {|format| format.json { render :json => { :msg => 'Something went wrong' } } }
      end
    else
      respond_to {|format| format.json { render :json => { :msg => %(#{@marker.name} already exists in this project) } } }
    end
  end

  def show_from_fasta
    respond_to{|format| format.html { render 'show_from_fasta', layout: request.xhr? ? false : 'application' } }
  end

  def remove_marker
    seq_marker = Molecular::Insd::Seq::SeqMarker.destroy(params["seq_marker_id"])
    msg = seq_marker.marker.nil? ? 'Removed marker from sequence' : %(Removed #{seq_marker.marker.name} from this sequence.)
    respond_to { |format| format.json { render :json => { :msg => msg, :id => params['id'] } } }
  end

  def new
    @taxon = Taxon.new
    @seq = current_project.sequences.new

    respond_to do |format|
      format.html { render :layout => false }
      format.xml  { render :xml => @seq }
    end
  end

  def new_from_genbank
    count, count_tax, @count_marker, already_there = 0,0,0,0
    params['seqs'].each do |sequence|
      seq = JSON.parse(sequence)
      if current_project.sequences.where('sequence = ? and locus = ? and organism = ? and definition = ?', seq['sequence'], seq['locus'], seq['organism'], seq['definition']).empty?
        taxa = passkey.unlock(Taxon)
        existing = taxa.where('name = ?', seq['organism'])
        count_tax = existing.empty? ? count_tax : (count_tax + 1)
        taxon = existing.first || taxa.create!(:name => seq['organism'])
        new_seq = make_seq(seq)
        markers = seq['markers'].collect{|m| process_marker(m)}
        new_seq.taxon = taxon
        new_seq.sequence = nil if new_seq.sequence == 'genome'
        new_seq.save!
        markers.each { |mrkr| mrkr.each { |k,v| new_seq.seq_markers.create(:marker => k, :position => v) } }
        count = count + 1
      else
        already_there = already_there + 1
      end
    end
    respond_to { |format| format.json { render :json => { :counts => { :num_seqs => count, :num_tax => count_tax, :num_marker => @count_marker, :already => already_there } } } }
  end

  def make_seq genbank_seq
    seq = current_project.sequences.new()
    seq.attributes.each{|k,v| seq[k] = genbank_seq[k] if genbank_seq.has_key?(k) }
    return seq
  end
  
  def process_marker(gb_seq)
    if current_project.markers.where('type = ? and lower_name = ?', gb_seq["type"], gb_seq["name"].downcase).empty?
        @count_marker = @count_marker + 1
        mrkr = current_project.markers.new
        mrkr.attributes.each{|k,v| mrkr[k] = gb_seq[k] if gb_seq.has_key?(k)}
        mrkr.save!
        return { mrkr => gb_seq["position"] }
      else
        return { current_project.markers.where('type = ? and lower_name = ?', gb_seq["type"], gb_seq["name"].downcase).first => gb_seq["position"] }
      end
  end

  def process_markers(genbank_seq)
    return genbank_seq["markers"].collect do |marker|
      if current_project.markers.where('type = ? and lower_name = ?', marker["type"], marker["name"].downcase).empty?
        @count_marker = @count_marker + 1
        mrkr = current_project.markers.new
        mrkr.attributes.each{|k,v| mrkr[k] = marker[k] if marker.has_key?(k)}
        mrkr.save!
        return { mrkr => marker["position"] }
      else
        return { current_project.markers.where('type = ? and lower_name = ?', marker["type"], marker["name"].downcase).first => marker["position"] }
      end
    end
  end

  def import
    #@seq = current_project.sequences.new
    respond_to do |format|
      format.html { render 'import', layout: request.xhr? ? false : 'application' }
    end
  end

  def create
    unless passkey.unlock(Taxon).where('name = ?', params['molecular_insd_seq']['taxon_name']).first.nil?
      Molecular::Insd::Seq.transaction do
        @seq = current_project.sequences.create!(params[:molecular_insd_seq].merge({:taxon_id => params['molecular_insd_seq'].delete('taxon_taxon_id'), :organism => params['molecular_insd_seq'].delete('taxon_name')}))
        newmarkersarray = params[:seq_marker].values.transpose.map{|a| Hash[params[:seq_marker].keys.zip(a)] } unless params[:seq_marker].nil?
        oldmarkersarray = params[:mol_marker].values.transpose.map{|a| Hash[params[:mol_marker].keys.zip(a)] } unless params[:mol_marker].nil?
        newmarkersarray.each { |marker|
          @seq.seq_markers.create!(:marker => current_project.markers.create!(marker.reject{|k,v| k == 'position' } ),
                                   :position => marker['position'])
        } if newmarkersarray
        if oldmarkersarray
          mapping = { 'id' => 'marker_id'}
          oldmarkersarray.each { |marker| Hash[marker.map{|k,v| [mapping[k], v] }] }
          oldmarkersarray.each { |marker| @seq.seq_markers.create!(marker) } if oldmarkersarray
        end
        if @seq.save then respond_to {|format| format.json { render :json => {:id => @seq.id}} }
        else
          msg = "Something went wrong"
          respond_to {|format| format.json { render :json => {:msg => msg}}}
        end
      end
    else
      msg = params['molecular_insd_seq']['taxon_name'].blank? ? "You have not entered a taxa name." : "No taxon found with name " + params['molecular_insd_seq']['taxon_name']
      respond_to {|format| format.json { render :json => {:msg => msg}}}
    end
  end

  #Genbank sequence submission changes - Open genabk sequence submission window
  def show_genbank_form
    @version_number = 1
    trunc_sequence = ''
    @attributes = get_attributes
    @userinfo = User.find_by_id(session[:user_id].to_i)
    ids = params[:conditions].match(/[0-9,]*/)[0]
    condition_arr = ids.split(',');
    session[:dnaseq] = nil
    dnaseqs = DnaGenbankInfo::Dnasequencecoll.new()
    length = 0
    condition_arr.each do |bioentry_id|
      length += 1
      dnafeats = DnaGenbankInfo::Seqfeaturecoll.new()
      #@seq_rel =  Molecular::Bioentry.find(bioentry_id.to_i)
      @insdsequence = Molecular::Insd::Seq.find(bioentry_id.to_i)
      #@seq_feature = SequenceFeature.find_all_by_seq_id(@seq_rel.uuid)
      @seq_feature = @insdsequence.features
      @seq_feature.each do |dnafeat|
        range = dnafeat.location.split("..")
        feat = DnaGenbankInfo::Seqfeature.new(dnafeat.key, dnafeat.quals[0].try(:name), dnafeat.quals[0].try(:value), range[0], range[1])
        dnafeats.add_seqfeatures(feat)
      end
      if !@insdsequence.sequence.nil? && @insdsequence.sequence.length > 20
        trunc_sequence = @insdsequence.sequence
        trunc_sequence = trunc_sequence[0..19] + "..."
      else
        trunc_sequence = @insdsequence.sequence
      end
      dnaseq = DnaGenbankInfo::Dnasequence.new(@insdsequence.pk, @insdsequence.definition, @insdsequence.sequence, '', trunc_sequence, length, dnafeats, @insdsequence.organism)
      dnaseqs.add_sequences(dnaseq)
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
      feat_count = params[:dnasequence][:feat_count].to_i
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
#        qual_array = qual.split('~');
#        qual_key = qual_array[1];
        qual_key = qual
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
      Molecular::Insd::Seq.transaction do
        @seq = Molecular::Insd::Seq.create!(
          :division => '',
          :definition =>  params[:dnasequence][:DNAseqTitle],
          :locus => 1,
          :project => @project,
          :creator_id => Integer(session[:user_id]),
          :organism => params[:dnasequence][:DNAOrg_name],
          :length => params[:dnasequence][:DNAseq].length,
          :moltype => 'dna',
          :sequence => params[:dnasequence][:DNAseq])
        dnafeats.each do |dnafeat|
          @seqfeat = @seq.features.create!(:location => dnafeat.seq_feat_start_loc + ".." +dnafeat.seq_feat_end_loc, :key => dnafeat.seq_feature )
          @seqfeat.quals.create!(:name => dnafeat.seq_feat_qualifier, :value => dnafeat.seq_feat_qual_value)
        end
      end
      dnaseq = DnaGenbankInfo::Dnasequence.new(@seq.pk, params[:dnasequence][:DNAseqTitle], params[:dnasequence][:DNAseq], params[:dnasequence][:DNAseqStrain], trunc_sequence, count, dnafeats, params[:dnasequence][:DNAOrg_name])
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
  end


  #validate the form on submission of batch sequences.
  def validate_genbank_data
    if params[:seq][:submit_title].blank?
      return "Citation title"
    end
    if params[:seq][:contact_lname].blank?
      return "Last name"
    end
    if params[:seq][:contact_fname].blank?
      return "First name"
    end
    if params[:seq][:contact_inst].blank? && params[:seq][:contact_dept].blank? && params[:seq][:contact_city].blank? && params[:seq][:contact_state].blank? && params[:seq][:contact_ctry].blank? && params[:seq][:contact_st].blank? && params[:seq][:contact_zip].blank?
      return "Affiliation"
    end
    if params[:seq][:contact_email].blank?
      return "Email id"
    end
    if params[:seq][:contact_phone].blank?
      return "Phone"
    end
    if params[:seq][:contact_zip].blank?
      return "Zipcode"
    end
    if params[:seq][:contact_ctry].blank?
      return "Country"
    end
    if params[:seq][:contact_state].blank?
      return "State"
    end
    if params[:seq][:contact_fax].blank?
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
              debugger
              ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier + "\t" + seqfeat.seq_feat_qual_value + "\n")
            else
              ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier  + "\n")
            end
            strfeat = seqfeat.seq_feature
          end
          if !seqfeat.seq_feat_qual_value.nil?
            debugger
            ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier + "\t" + seqfeat.seq_feat_qual_value + "\n")
          else
            ex_file.write ("\t\t\t" + seqfeat.seq_feat_qualifier  + "\n")
          end
          strfeat = seqfeat.seq_feature
        end
      end
      ex_file.close
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
      post_body << "#{params[:seq][:contact_fname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"last_name\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_lname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"department\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_dept]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"institution\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_inst]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"street\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_st]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"city\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_city]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"state\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_state]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"zip\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_zip]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"country\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_ctry]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"phone\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_phone]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"fax\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_fax]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"email\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_email]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_first_1\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_fname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_mi_1\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_mname]}\r\n"
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data\; name=\"author_last_1\"\r\n\r\n"
      post_body << "#{params[:seq][:contact_lname]}\r\n"
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
      post_body << "#{params[:seq][:submit_title]}\r\n"
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
      if !params[:seq][:rel].nil?
        release_date = params[:seq][:"publish_date(2i)"].to_s + "/" + params[:seq][:"publish_date(3i)"].to_s + "/" + params[:seq][:"publish_date(1i)"]
        #`#{RAILS_ROOT}/public/files/./tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s -H '#{release_date}'`
        `tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s -H '#{release_date}'`
      else
        #`#{RAILS_ROOT}/public/files/./tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s`
        `tbl2asn -t #{RAILS_ROOT}/public/files/template.sbt -p #{RAILS_ROOT}/public/files/ -V v -s`
      end
      #Send mail to genbank
      mail = IssueMailer.create_sendmail(params[:seq][:contact_email], params[:seq][:submit_title])
      IssueMailer.deliver(mail)
      #save_sequence_feature_records
      
      flash[:notice] = 'Sequence submission was successfully sent.'
      session[:dnaseq] = nil
      debugger
      respond_to do |format|
        format.html { redirect_to(project_molecular_sequences_path(params[:project_id])) }
        format.js
      end
    end
  end

  def delete_selected
    super current_project.sequences
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
      seqs << Molecular::Insd::Seq.find(id).sequence
    end

    a = Bio::Alignment.new(seqs)
    a.consensus
    a.consensus_iupac()
    a.each{|x| p x}
    a.each_site{|x| p x}
    opts = Array.new
    params[:align].each{ |key,value| opts << "-#{key}=#{value}" }
    factory = Bio::ClustalW.new('clustalw', opts)

    aligned = a.do_align(factory)

    align = Molecular::Alignment.create(:name => params[:title], :description => params[:description], :seq => aligned.to_fasta)

    render json: {id: align.id}
  end

  def remove_probe_from_insd_seq
    @seq = current_project.sequences.find(params[:id])
#    validate(params) && parse(params)
#    probes = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',')
#    @resource = current_project.probes
#    probes = @resource.scoped.apply_finder_options(prepare(params, for: :finder))
#    probes = @seq.probes.find(params[:conditions])

    params[:probeIds] ? probes = @seq.probes.find(params[:probeIds]) :
        probes = @seq.probes.find(params[:conditions])

    probes.each do |probe|
      #@probe = current_project.probes.find(probe)
      @seq.probes.delete(probe)
    end


    #respond_to do |format|
    #  format.html {redirect_to :back, :notice => 'Probe successfully removed from the Sequence.'}
    #  format.xml { head :ok}
    #end

    @probes = @seq.probes.order(:id).limit(10).paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html { render :partial => 'seq_probes_list_and_paginate'}
      format.xml { head :ok}
    end
  end

  def assign_probe_to_insd_seq
    @seq = current_project.sequences.find(params[:id])
    validate(params) && parse(params)
    @resource = current_project.probes
    probes = @resource.scoped.apply_finder_options(prepare(params, for: :finder))
    duplicate_probe_ids = []


    params[:probeIds].each do |probe|
      @seq.probes << current_project.probes.find(probe)  if @seq.probes.where("id=#{probe}").empty?
    end

    #      ids = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',')
    #probes.each do |probe|
    #
    #  unless @seq.probes.include?(probe)
    #    @seq.probes << probe
    #  else
    #    probe_value = probe.value
    #    duplicate_probe_ids << probe
    #    duplicate_probe_values << probe.value
    #  end
    #end

    #    probes.each do |probe|
    #      probe.update_attributes({:sequence_contig_id => params[:id]})
    #    end

    @probes = @seq.probes.order(:id).limit(10).paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html {render :partial => 'seq_probes_list_and_paginate'}
      format.xml { head :ok}
    end

    #respond_to do |format|
    #  @status = :ok
    #  format.json { render json: duplicate_probe_values.to_json }
    #end
  end

  def search

    if params[:term].blank?
      @probes = current_project.probes.order(:id).limit(10).paginate(:page => params[:page], :per_page => 10)
    else

#    @images = current_project.images.order(:id).paginate(:page => params[:page], :per_page => 55)
#    #:include => {:parent => {:image_taxon => :taxon, :image_collection => :collection}},
#    #:conditions => {'images.project_id' => @current_project}
#    taxon_ids = []
#
##    @images.each do |image|
##      taxon_ids << image.image_joins.first[:object_id]
##
##    end
##    respond_to do |format|
##       format.html { render 'index', layout: request.xhr? ? false : true }
##      format.xml  { render :xml => @images }
## end
#        debugger
#    render 'index'

      @probes = []
      case params[:search]
        when 'value'
          query = current_project.probes.where("probes.value iLIKE '%#{params[:term]}%'")
        #query = current_project.probes.find_by_sql("SELECT  * FROM probes WHERE project_id = '#{params[:project_id]}' AND lower(value) LIKE '%#{params[:term].downcase}%'")
        #query = current_project.images.where(:caption => "#{params[:term]}").order(:id)
        when 'probe_type'
          query = current_project.probes.where("probes.probe_type iLIKE '%#{params[:term]}%'")
        when 'southern_signal'
          query = current_project.probes.where("probes.southern_signal iLIKE '%#{params[:term]}%'")
        when 'fish_signal'
          query = current_project.probes.where("probes.fish_signal iLIKE '%#{params[:term]}%'")
      end

      query.each do |probe|
        @probes << probe

      end
      @probes = @probes.paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.html { render :partial => 'probes_list_and_paginate' }
      format.xml  { render :xml => @seq }
    end

    #render 'index'
  end

  def assigned_search
    @seq = current_project.seqs.find(params[:id])

    if params[:term].blank?
      @probes = @seq.probes.order(:id).limit(10).paginate(:page => params[:page], :per_page => 10)
    else

#    @images = current_project.images.order(:id).paginate(:page => params[:page], :per_page => 55)
#    #:include => {:parent => {:image_taxon => :taxon, :image_collection => :collection}},
#    #:conditions => {'images.project_id' => @current_project}
#    taxon_ids = []
#
##    @images.each do |image|
##      taxon_ids << image.image_joins.first[:object_id]
##
##    end
##    respond_to do |format|
##       format.html { render 'index', layout: request.xhr? ? false : true }
##      format.xml  { render :xml => @images }
## end
#        debugger
#    render 'index'

      @probes = []
      case params[:search]
        when 'value'
          query = @seq.probes.where("probes.value iLIKE '%#{params[:term]}%'")
        #query = @seq.probes.find_by_sql("SELECT  * FROM probes RIGHT JOIN probes_seqs ON probes.id = probes_seqs.probe_id WHERE value iLIKE '%#{params[:term]}%'")
        #query = current_project.images.where(:caption => "#{params[:term]}").order(:id)
        when 'probe_type'
          query = @seq.probes.where("probes.probe_type iLIKE '%#{params[:term]}%'")
        when 'southern_signal'
          query = @seq.probes.where("probes.southern_signal iLIKE '%#{params[:term]}%'")
        when 'fish_signal'
          query = @seq.probes.where("probes.fish_signal iLIKE '%#{params[:term]}%'")
      end

      query.each do |probe|
        @probes << probe

      end
      @probes = @probes.paginate(:page => params[:page], :per_page => 10)
    end

    respond_to do |format|
      format.html { render :partial => 'seq_probes_list_and_paginate' }
      format.xml  { render :xml => @seq}
    end

    #render 'index'
  end
end

