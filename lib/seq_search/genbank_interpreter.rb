module SeqSearch
  module GenbankInterpreter

    def assemble_seqs data
      seqs = data.collect{ |datum| convert_to_tolkin(datum) }
      #seqs = (type == 'fasta') ? parse_fasta(data) : parse_gbset(data)
      return seqs
    end

    def convert_to_tolkin gb_seq
      { :organism   => gb_seq.organism,
        :locus      => gb_seq.locus.entry_id,
        :markers    => gb_seq.features.inject([]){ |memo, feat|
                        if ['gene', 'rrna', 'misc_rna'].include? feat.feature.downcase
                          split_position = feat.position.split('..')
                          memo << { :type => feat.feature,
                                    :start_position => split_position.first[/\d+/],
                                    :end_position => split_position.last[/\d+/],
                                    :name => feat.qualifiers.first.value }
                        else
                          memo
                        end },
        :definition => gb_seq.definition,
        :sequence   => gb_seq.seq.upcase }
    end

    def parse_fasta data
      if data.nil?
        debugger
      else
        debugger
      end
    end

    def parse_gbset data
      ids_for_fasta = {}
      gb_seqs = data['GBSet']['GBSeq'].is_a?(Array) ? data['GBSet']['GBSeq'] : [data['GBSet']['GBSeq']]
      seqs = gb_seqs.collect do |gbseq|
        seq = convert_gbseq(gbseq)
        seq[:gb_metadata] = gbseq.to_s
        if seq[:sequence].nil?
          if seq[:definition].include?('genom')
            seq[:sequence] = 'genome (accessible later)'
          else
            seq[:sequence] = 'unavailable (accessible later)'
          end
        end
        if (seq[:marker].nil? && seq[:sequence].include?('genome'))
          seq[:marker] = { :name => 'genome' }
        elsif (seq[:marker].nil? && !seq[:sequence].include?('genome')) || (!seq[:marker][:name].is_a?(String))
          seq[:marker] = { :name => 'unknown' }
        end
        seq.delete(:other_seqids)
        ##TODO: Get :other_seqids for links to other database(s) -- THESE ARNT ACTUALLY AVAILABLE.  DISCUS TAXON LINK
        seq.delete(:references)
        seq.delete(:feature_table)
        seq.delete(:project) if seq[:project]
        seq
      end
      seqs
    end

    def convert_gbseq(gbseq)
      gbseq.inject({}) do |memo, (k, v)|
        if k.start_with?('GBSeq_')
          memo[k.sub('GBSeq_', '').to_sym] = v if v.is_a?(String)
        end
        if v.is_a?(Hash) && v.has_key?('GBFeature')
          memo[:marker] = { :name => get_gene(flattenize(v['GBFeature']))} || nil
        end
        #if v.is_a?(Hash) && v.has_key?('GBSeqid')
        #  debugger if v['GBSeqid'].count > 2
        #end
        memo
      end
    end

    def get_gene array
      array.each_with_index {|item, index| return array[index+3] if (item == 'GBQualifier_name' && array[index+1] == 'gene') }
    end

    def flattenize obj
      case obj
        when Hash, Array then obj.to_a.collect{ |i| flattenize(i) }.flatten
        else obj.to_s
      end
    end

  end
end