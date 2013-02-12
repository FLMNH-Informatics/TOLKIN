# To change this template, choose Tools | Templates
# and open the template in the editor.

module DnaGenbankInfo

  class Seqfeaturecoll < Array
    def add_seqfeatures(seqfeature)
      self << seqfeature
    end
  end

  class Dnasequencecoll < Array
#    attr_reader :dnasequences
#    attr_writer :dnasequences
#    def initialize()
#      @dnasequences = Array.new
#    end

    def add_sequences(dnasequence)
      self << dnasequence
      #@dnasequences << dnasequence
    end

#    def iterate
#      @dnasequences.each{ | seq | yield seq }
#    end

  end

  class Dnasequence
    attr_reader :seq_id, :seq_title, :sequence, :seq_strain, :trunc_sequence, :seq_count, :seq_features, :organism_name
    attr_writer :seq_id, :seq_title, :sequence, :seq_strain, :trunc_sequence, :seq_count, :seq_features, :organism_name

    def initialize(seq_id, seq_title, sequence, seq_strain, trunc_sequence, seq_count, seq_features, organism_name)
      @seq_id = seq_id
      @seq_title = seq_title
      @sequence = sequence
      @seq_strain= seq_strain
      @trunc_sequence = trunc_sequence
      @seq_count = seq_count
      @seq_features = seq_features
      @organism_name = organism_name
    end
  end

  class Seqfeature
    attr_reader :seq_feature, :seq_feat_qualifier, :seq_feat_qual_value, :seq_feat_start_loc, :seq_feat_end_loc
    attr_writer :seq_feature, :seq_feat_qualifier, :seq_feat_qual_value, :seq_feat_start_loc, :seq_feat_end_loc

    def initialize(seq_feature, seq_feat_qualifier, seq_feat_qual_value, seq_feat_start_loc, seq_feat_end_loc)
      @seq_feature = seq_feature
      @seq_feat_qualifier = seq_feat_qualifier
      @seq_feat_qual_value = seq_feat_qual_value
      @seq_feat_start_loc = seq_feat_start_loc
      @seq_feat_end_loc = seq_feat_end_loc
    end
  end
end
