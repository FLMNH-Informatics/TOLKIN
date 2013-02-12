# To change this template, choose Tools | Templates
# and open the template in the editor.

module GenbankSearch
  def self.included(klass)
    class << klass
      def get_filters
        searchable_columns
      end

      def generic_search(search_params, selected_filters, extra_params = {})
        GenericSearchHelper::Helper.sanitize!(search_params, selected_filters)
        #Collection.searchlogic({:limit => 10}.merge(search_params || {}))
        search_params = search_params || {}
        self.searchlogic(search_params.merge(extra_params))
      end

      private

      def searchable_columns
        @searchable_columns ||= {
          accession:         { name: :accession, type: :string },
          all_fields:        { name: :all_fields, type: :string },
          author:            { name: :author, type: :string },
          ecrn_number:       { name: :ecrn_number, type: :string },
          feature_key:       { name: :feature_key, type: :string },
          filter:            { name: :filter, type: :string },
          gene_name:         { name: :gene_name, type: :string },
          genome_project:    { name: :genome_project, type: :string },
          issue:             { name: :issue, type: :string },
          journal:           { name: :journal, type: :string },
          keyword:           { name: :keyword, type: :string },
          modification_date: { name: :modification_date, type: :string },
          organism:          { name: :organism, type: :string },
          page_number:       { name: :page_number, type: :string },
          primary_accession: { name: :primary_accession, type: :string },
          primary_organism:  { name: :primary_organism, type: :string },
          properties:        { name: :properties, type: :string },
          protein_name:      { name: :protein_name, type: :string },
          publication_date:  { name: :publication_date, type: :string },
          seqid_string:      { name: :seqid_string, type: :string },
          sequence_length:   { name: :sequence_length, type: :string },
          substance_name:    { name: :substance_name, type: :string },
          text_word:         { name: :text_word, type: :string },
          title:             { name: :title, type: :string },
          volume:            { name: :volume, type: :string }
        }
      end
    end
  end
end
