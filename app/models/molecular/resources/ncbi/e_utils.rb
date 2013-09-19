require 'timeout'
require 'bio'

class Molecular::Resources::Ncbi::EUtils

  class << self
    REQUEST_PARAMS_TO_ESEARCH_PARAMS = [
      { from: :offset, to: :retstart},
      { from: :search, to: :term, through: :parse_terms }
    ]
    SEARCH_PARAMS_TO_ESEARCH_TERM_PARAMS = [
      #{ from: :description, to: :title }
    ]
    NCBI_SEARCH_FIELD_QUALIFIERS = {
      accession:         'ACCN',
      all_fields:        'ALL',
      author:            'AUTH',
      ecrn_number:       'ECNO',
      feature_key:       'FKEY',
      filter:            'FILT',
      gene_name:         'GENE',
      genome_project:    'GENOME PROJECT',
      issue:             'ISS',
      journal:           'JOUR',
      keyword:           'KYWD',
      modification_date: 'MDAT',
      organism:          'ORGN',
      page_number:       'PAGE',
      primary_accession: 'PACC',
      primary_organism:  'PORGN',
      properties:        'PROP',
      protein_name:      'PROT',
      publication_date:  'PDAT',
      seqid_string:      'SQID',
      sequence_length:   'SLEN',
      substance_name:    'SUBS',
      text_word:         'WORD',
      title:             'TITL',
      volume:            'VOL'


    }

    def esearch options = {}
      #trans_key = REQUEST_PARAMS_TO_ESEARCH_PARAMS
      #esearch_params = translate_params(options, trans_key)
      esearch_params = {}
      esearch_params.merge!(options) unless options.nil?
      start_params = {  tool:       'tokin',
                        email:      'tolkin@flmnh.ufl.edu',
                        db:         'nucleotide',
                        usehistory: 'y'
                     }
      parameters = start_params.merge(esearch_params)
      html_params = parameters.keys.collect { |key| "#{key.to_s}=#{parameters[key].to_s.gsub(/\s+/, '+')}" }.join('&')
      Timeout::timeout(5) { @response = Net::HTTP.get('eutils.ncbi.nlm.nih.gov', "/entrez/eutils/esearch.fcgi?#{html_params}") }
      Molecular::Resources::Ncbi::EUtils::ESearch.from_xml(@response)
    rescue Timeout::Error
      fail Ncbi::TimeoutError
    end

    def esummary ids
      response = Net::HTTP.get('eutils.ncbi.nlm.nih.gov', "/entrez/eutils/esummary.fcgi?db=nucleotide&id=#{ [*ids].join(',') }&retmax=20")
      Molecular::Resources::Ncbi::EUtils::ESummary.from_xml(response)
    end

    def epost ids
      response = Net::HTTP.get('eutils.ncbi.nlm.nih.gov', "/entrez/eutils/epost.fcgi?db=nucleotide&id=#{ [*ids].join(',') }&retmax=20")
      Molecular::Resources::Ncbi::EUtils::EPost.from_xml(response)
    end

    def efetch_ids ids
      response = Net::HTTP.get('eutils.ncbi.nlm.nih.gov', "/entrez/eutils/efetch.fcgi?db=nuccore&id=#{ [*ids].join(',') }&retmax=20&retmode=xml&rettype=fasta")
      Hash.from_xml(response)
    end

    def efetch(webenv, querykey, start, num)
      response = Net::HTTP.get('eutils.ncbi.nlm.nih.gov', "/entrez/eutils/efetch.fcgi?db=nucleotide&webenv=#{ webenv }&rettype=gb&retmode=text&query_key=#{ querykey }&retstart=#{ start }&retmax=#{ num }&sort=accession" )
      Molecular::Resources::Ncbi::EUtils::EFetch.from_text(response)
      #Hash.from_xml(response) TRYING BIORUBY's parser instead, may be faster
    end

    private

    def translate_params start_params, trans_array
      trans_array.inject({}) do |acc, trans_step|
        through_method = trans_step[:through] ? method(trans_step[:through]) : lambda{|v| v }
        acc[trans_step[:to]] = through_method.call(start_params[trans_step[:from]]) if start_params[trans_step[:from]]
        acc
      end
    end

    def parse_terms start_params
      trans_key      = SEARCH_PARAMS_TO_ESEARCH_TERM_PARAMS
      qualifiers_key = NCBI_SEARCH_FIELD_QUALIFIERS
      params = start_params

      trans_key.each do |trans_step|
        params[trans_step[:to]] = params.delete(trans_step[:from]) if params[trans_step[:from]]
      end

      final_params = params.inject({}) do |acc, (k,v)|
        acc[qualifiers_key[k.sub(/_like/,'').to_sym]] = v
        acc
      end
      #final_params.collect{|k,v| v.split(' ').collect{|vsub|"#{vsub}[#{k}]" }.join('+') }.join('+') # turn {TITL: 'Campanula propinqua' ACC: 'HSX'} into 'Campanula[TITL]+propinqua[TITL]+HSX[ACC]'
      final_params.collect{|k,v| "#{v}[#{k}]" }.join(' AND ') # turn {TITL: 'Campanula propinqua' ACC: 'HSX'} into 'Campanula%20propinqua[TITL]+HSX[ACC]'
    end
  end
end
