module Molecular::Insd::SeqsHelper
  include Molecular::MarkersDisplay


  def fasta_filenames_select
    select_concat(Molecular::FastaFilename, current_project, ['filename', 'upload_date'])
  end

  def action_list_id
    'viewport_insd_seqs_user_panel_insd_seqs_action_list'
  end

  def taxon_name
    interact_mode == "browse" ? @seq.organism.to_s : taxon_name_field
  end
  
  def more_data
    %(<div id="show_gb_detailed_data">#{ncbi_data}#{gb_link}</div>)
  end

  def ncbi_data
    '(<a id="more_ncbi">show ncbi data</a>)' unless @seq.gb_metadata.blank?
  end

  def gb_link
    '(<a target="_blank" href="http://www.ncbi.nlm.nih.gov/nuccore/' + @seq.locus.to_s + '" >view genbank <img width="11" height="9" src="/images/new_window_icon.gif" alt="new window" /></a>)'unless @seq.locus.blank?
  end

  def seq_browse
    %(<div class="seq_wrap">&nbsp;&nbsp;&nbsp;#{@seq.sequence.upcase}</div>)
  end

  def sequence_control
    interact_mode == "browse" ? seq_browse : text_area(:seq, :sequence, :size => "111x6" ).upcase
  end

  def definition
    interact_mode == "browse" ? ("&nbsp;&nbsp;&nbsp;" + @seq.definition.to_s) : text_area(:seq, :definition, :size => "51x5")
  end

  def taxonomy
    interact_mode == "browse" ? ("&nbsp;&nbsp;&nbsp;" + @seq.taxonomy.to_s) : text_area(:seq, :taxonomy, :size => "51x5")
  end

  def comment
    interact_mode == "browse" ? (@seq.comment.blank? ? '' : ("&nbsp;&nbsp;&nbsp;" + @seq.comment.to_s)) : text_area(:seq, :comment, :size => "111x6")
  end

  def source
    interact_mode == "browse" ? return_something(@seq.source.to_s) : text_field(:seq, :source, :size => 20)
  end

  def length
    interact_mode == "browse" ? return_something(@seq.length.to_s) : text_field(:seq, :length, { :size => 20, :enabled => 'false' })
  end

  def strandedness
    interact_mode == "browse" ? return_something(@seq.strandedness.to_s) : text_field(:seq, :strandedness, :size => 20)
  end

  def moltype
    interact_mode == "browse" ? return_something(@seq.moltype.to_s) : text_field(:seq, :moltype, :size => 20)
  end

  def topology
    interact_mode == "browse" ? return_something(@seq.topology.to_s) : text_field(:seq, :topology, :size => 20)
  end

  def division
    interact_mode == "browse" ? return_something(@seq.division.to_s) : text_field(:seq, :division, :size => 20)
  end

  def locus
    interact_mode == "browse" ? return_something(@seq.locus.to_s) : text_field(:seq, :locus, :size => 20)
  end

  def primary_accession
    interact_mode == "browse" ? return_something(@seq.primary_accession.to_s) : text_field(:seq, :primary_accession, :size => 20)
  end

  def entry_version
    interact_mode == "browse" ? return_something(@seq.entry_version.to_s) : text_field(:seq, :entry_version, :size => 20)
  end

  def accession_version
    interact_mode == "browse" ? return_something(@seq.accession_version.to_s) : text_field(:seq, :accession_version, :size => 20)
  end

  #def marker_name
  #  interact_mode == "browse" ? return_something(@seq.marker.name.to_s) : marker_name_select
  #end

  def marker_select_concat
    select_concat(Molecular::Marker, current_project, ['name', 'type'], '.')
  end

  #def fasta_filenames_select
  #  max = current_project.fasta_filenames.inject(0){|memo,ff| memo = ff.filename.length > memo ? ff.filename.length : memo }
  #  html_options = []
  #  current_project.fasta_filenames.all(:order => 'filename, upload_date desc').each do |ff|
  #    pads = max - ff.filename.length
  #    space = "&".html_safe + "nbsp;".html_safe
  #    filename = ff.filename + space*pads + space*2 + "-" + space*2 + ff.upload_date.to_datetime.to_formatted_s(:long)
  #  html_options.push([raw(filename), ff.id])
  #end
  #select("fasta_filename", "id", html_options, {:include_blank => true}, {:style => 'font-family:monospace;'})
  #end

  def marker_name_select
    select('seq_marker', 'marker_id[]', Molecular::Marker.for_project(current_project).sort_by{ |m| m.name }.collect{ |m| [m.name, m.id] })
  end

  def unfiltered_ncbi
    %(<textarea id="seq_gb_metadata" rows="10" cols="111" name="seq[gb_metadata]">#{@seq.gb_metadata}</textarea>)
  end

  def seq_dates type, form
    #interact_mode == "browse" ? return_something(@seq[type]) : %(&nbsp;&nbsp;&nbsp;#{ date_select(:seq, type.parameterize.underscore.to_sym, {:value => @seq[type], :include_blank => true, :default => nil, :end_year => Time.now.year, :start_year => 1900}) })
    interact_mode == "browse" ? return_something(@seq[type]) : %(&nbsp;&nbsp;&nbsp;#{ date_field(@seq, type.parameterize.underscore.to_sym, { :value => @seq[type], :form_builder =>  form, :object_name => 'seq' } ) })
  end

  def return_something(attribute)
    attribute.blank? ? 'n/a' : attribute
  end

  def imode_spacing options = {}
    interact_mode == "browse" ? '<td>|</td>' : (options.is_a?(Hash) ? '</tr><tr>' : '</tr><tr><td class="td_indent">&nbsp;</td>')
  end

  def txt_align
    interact_mode == "browse" ? '' : 'style="text-align: right;"'
  end

  def col_marg
    interact_mode == "browse" ? 'style="padding-left: 10px;"' : ''
  end

  #def new_marker_link
  #  interact_mode == "browse" ? '' : '(<a class="toggle_marker_control">+new</a>)(<a class="toggle_marker_control">+existing</a>)'
  #end

  def seqs_action_panel
    Widgets::Insd::Seqs::Catalogs::ActionPanel.new({
      parent: viewport
    })
  end

  def test
    'test'
  end

  def horizontal_divider
    interact_mode == "browse" ? %(<table class="table_width"><tr><td><hr></td></tr></table>) : ''
  end

  def fetch_gb_seq
    interact_mode == "browse" ? '' : (@seq.sequence.include?('genome') ? '(<a id="fetch_gb_seq">fetch sequence from NCBI</a>)' : '')
  end

  

  def taxon_name_field
    @taxon_name_field ||= Molecular::Insd::Seqs::TaxonNameAutoTextField.new({
      context: self,
      model_object: @seq,
      parent: viewport_window
    })
  end

  #def taxon_auto_complete_field(f)
  #  Molecular::Insd::Seqs::TaxonAutoCompleteField.new({
  #    seq: f.object,
  #    parent: viewport_window,
  #    context: self
  #  })
  #end

  def seqs_catalog
     Molecular::Insd::Seqs::Catalog.new({
      collection: @seqs,
      parent: content_frame
    }).render_to_string
#    catalog('bioentries_inner_catalog', @requested, [
#        { :attribute => "name", :width => 250 },
#        { :attribute => "otu_groups", :map => 'name', :width => 200 },
#        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
#      ], :count => @count
#    )
  end

  #def probes_catalog
  #  Molecular::Insd::Seqs::Probescatalog.new({
  #      collection: @probes,
  #      parent: content_frame
  #    }).render_to_string
  #
  #end
  #
  #def seq_probes_catalog
  #  Molecular::Insd::Seqs::Seqprobescatalog.new({
  #      collection: @seq_probes,
  #      parent: content_frame
  #    }).render_to_string
  #
  #end

  def probes_list
    Molecular::Insd::Seqs::ProbesList.new({
        context: self,
        probes: @probes1,
        parent: content_frame })
  end

  def seq_probes_list
    Molecular::Insd::Seqs::SeqProbesList.new({
        context: self,
        probes: @seq_probes1,
        parent: content_frame })
  end

end
