class TemplatesController < ApplicationController

  TemplateNotFoundException = Class.new(StandardError)

  def show
    @templates = { }
    template_paths = params[:template_paths].split(',')#.join('/').split(',')
    template_paths.each do |short_path|
      erb_path = 'app/views/' + short_path + '.html.erb'
      haml_path = 'app/views/' + short_path + '.html.haml'
      if File.exists?(haml_path)
        full_path = haml_path
      elsif File.exists?(erb_path)
        full_path = erb_path
      else
        full_path = nil
      end
      raise(TemplateNotFoundException, "template '#{short_path}' could not be accessed") unless allowed_templates.include?(short_path) && full_path
      File.open(full_path, 'r') { |file| @template_text = file.read } #rescue fail("error reading file at path #{full_path}")
      if full_path == haml_path
        @templates.merge!({ short_path => Haml2Erb.convert(@template_text)})
      elsif full_path == erb_path
        @templates.merge!({ short_path => @template_text })
      end
    end
    respond_to do |format|
      format.json { render :json => @templates, :content_type => 'application/json' }
    end
  end

  private

  def allowed_templates
    @allowed ||= [
      'collections/_window',
#      'collections/catalogs/_action_panel',
      'collections/show',
      'collections/_annotations_catalog_action_panel',
      'collections/_iso_country_select',
      'filters/_form',
      'forms/_date_field',
      'molecular/insd/seqs/_details',
      'molecular/insd/seqs/_new_alignment_window',
      'molecular/insd/seqs/show',
      'layouts/window',
      'molecular/alignments/new',
      'molecular/alignments/show',
      'molecular/matrix/cells/cell_details',
      'molecular/alignments/catalogs/_action_panel',
      'molecular/dna_samples/catalogs/_action_panel',
      'molecular/matrices/catalogs/_action_panel',
      'molecular/matrices/otu_groups/catalogs/_action_panel',
      'molecular/primers/_new_primer_window',
      'molecular/primers/_primer_details',
      'morphology/matrices/otu_groups/catalogs/_action_panel',
      'ncbi/seqs/index',
      'otus/catalogs/_action_panel',
      'widgets/_catalog',
      'widgets/_combo_box',
      'widgets/catalogs/_entry',
      'shared/_generic_dialog',
      'shared/_list_citations_taxa',
      'shared/_yes_no_dialog',
      'shared/panes/_versioning_pane_changes_list',
      #'taxa/_new',
      'taxa/_node',
      'taxa/_taxon_details',
      'taxa/catalogs/_action_panel',
      'taxa/tree_views/_action_panel',
      'taxa/show',
      'taxa/list',
      'shared/_image_display_for_species_page',
      'shared/_past_searches',
      'molecular/dna_samples/_dna_details',
      'otus/catalogs/_action_panel',
      'otu_groups/catalogs/_action_panel',
      'otu_groups/_new_otu_group',
      'morphology/matrices/catalogs/_action_panel',
      'morphology/characters/catalogs/_action_panel',
      'morphology/chr_groups/catalogs/_action_panel',
      'library/citations/catalogs/_action_panel',
      'library/citations/_authors_catalog_action_panel',
      'library/publications/catalogs/_action_panel',
      'library/publishers/catalogs/_action_panel'
    ]
  end
end
