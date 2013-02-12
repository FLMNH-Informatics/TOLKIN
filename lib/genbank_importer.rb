require 'bio'

class GenbankImporter
  def import ids
    xml = Bio::NCBI::REST::EFetch.sequence(ids, 'xml')
    @document = Hpricot(xml)
    Insd::Seq.transaction do
      import_seqs
    end
  end

  private

  def import_seqs
    (@document/'/INSDSet/INSDSeq').each do |seq_node|
      seq = Insd::Seq.create!(
        locus:              (seq_node/'/INSDSeq_locus').inner_html,
        length:             (seq_node/'/INSDSeq_length').inner_html,
        strandedness:       (seq_node/'/INSDSeq_strandedness').inner_html,
        moltype:            (seq_node/'/INSDSeq_moltype').inner_html,
        topology:           (seq_node/'/INSDSeq_topology').inner_html,
        division:           (seq_node/'/INSDSeq_division').inner_html,
        update_date:        (seq_node/'/INSDSeq_update-date').inner_html,
        create_date:        (seq_node/'/INSDSeq_create-date').inner_html,
        update_release:     (seq_node/'/INSDSeq_update-release').inner_html,
        create_release:     (seq_node/'/INSDSeq_create-release').inner_html,
        definition:         (seq_node/'/INSDSeq_definition').inner_html,
        primary_accession:  (seq_node/'/INSDSeq_primary-accession').inner_html,
        entry_version:      (seq_node/'/INSDSeq_entry-version').inner_html,
        accession_version:  (seq_node/'/INSDSeq_accession-version').inner_html,
        project:            (seq_node/'/INSDSeq_project').inner_html,
        segment:            (seq_node/'/INSDSeq_segment').inner_html,
        source:             (seq_node/'/INSDSeq_source').inner_html,
        organism:           (seq_node/'/INSDSeq_organism').inner_html,
        taxonomy:           (seq_node/'/INSDSeq_taxonomy').inner_html,
        comment:            (seq_node/'/INSDSeq_comment').inner_html,
        primary:            (seq_node/'/INSDSeq_primary').inner_html,
        source_db:          (seq_node/'/INSDSeq_source-db').inner_html,
        database_reference: (seq_node/'/INSDSeq_database-reference').inner_html,
        feature_set_pk:     feature_set(seq_node/'/INSDSeq_feature-set/INSDFeatureSet').pk,
        sequence:           (seq_node/'/INSDSeq_sequence').inner_html,
        contig:             (seq_node/'/INSDSeq_contig').inner_html,
        alt_seq_pk:         alt_seq_data(seq_node/'/INSDSeq_alt-seq/INSDAltSeqData').pk
      )
      import_other_seqids seq, seq_node
      import_secondary_accns seq, seq_node
      import_keywords seq, seq_node
      import_references seq, seq_node
      import_comments seq, seq_node
      import_struc_comments seq, seq_node
      import_feature_table seq, seq_node
    end
  end

  def alt_seq_data data_node
    data = Insd::AltSeqData.create!(
      name: (data_node/'/INSDAltSeqData_name').inner_html
    )
    (data_node/'/INSDAltSeqData_items/INSDAltSeqItem').each do |item_node|
      alt_seq_data_item(data.items, item_node)
    end
    data
  end

  def alt_seq_data_item item_source, item_node
    item_source.create!(
      interval:    (item_node/'/INSDAltSeqItem_interval').inner_html,
      isgap:       (item_node/'/INSDAltSeqItem_isgap').inner_html,
      gap_length:  (item_node/'/INSDAltSeqItem_gap-length').inner_html,
      gap_type:    (item_node/'/INSDAltSeqItem_gap-type').inner_html,
      gap_linkage: (item_node/'/INSDAltSeqItem_gap-linkage').inner_html,
      gap_comment: (item_node/'/INSDAltSeqItem_gap-comment').inner_html,
      first_accn:  (item_node/'/INSDAltSeqItem_first-accn').inner_html,
      last_accn:   (item_node/'/INSDAltSeqItem_last-accn').inner_html,
      value:       (item_node/'/INSDAltSeqItem_value').inner_html
    )
  end

  def feature_set feature_set_node
    feature_set = Insd::FeatureSet.create!(
      annot_source: (feature_set_node/'/INSDFeatureSet_annot-source').inner_html
    )
    (feature_set_node/'/INSDFeatureSet_features/INSDFeature').each do |feature_node|
      feature feature_set.features, feature_node
    end
    feature_set
  end

  def feature feature_source, feature_node
    feature = feature_source.create!(
      key:      (feature_node/'/INSDFeature_key').inner_html,
      location: (feature_node/'/INSDFeature_location').inner_html,
      operator: (feature_node/'/INSDFeature_operator').inner_html,
      partial5: (feature_node/'/INSDFeature_partial5').inner_html,
      partial3: (feature_node/'/INSDFeature_partial3').inner_html
    )
    import_intervals feature, feature_node
    import_qualifiers feature, feature_node
    import_xrefs feature, feature_node
  end

  def import_feature_table seq, seq_node
    (seq_node/'/INSDSeq_feature-table/INSDFeature').each do |feature_node|
      feature seq.features, feature_node
    end
  end

  def import_xrefs feature, feature_node
    (feature_node/'/INSDFeature_xrefs/INSDXref').each do |xref_node|
      feature.xrefs << xref(xref_node)
    end
  end

  def import_qualifiers feature, feature_node
    (feature_node/'/INSDFeature_quals/INSDQualifier').each do |qualifier_node|
      feature.quals.create!(
        name:  (qualifier_node/'/INSDQualifier_name').inner_html,
        value: (qualifier_node/'/INSDQualifier_value').inner_html
      )
    end
  end

  def import_intervals feature, feature_node
    (feature_node/'/INSDFeature_intervals/INSDInterval').each do |interval_node|
      feature.intervals.create!(
        from:      (interval_node/'/INSDInterval_from').inner_html,
        to:        (interval_node/'/INSDInterval_to').inner_html,
        point:     (interval_node/'/INSDInterval_point').inner_html,
        iscomp:    (interval_node/'/INSDInterval_iscomp').inner_html,
        interbp:   (interval_node/'/INSDInterval_interbp').inner_html,
        accession: (interval_node/'/INSDInterval_accession').inner_html
      )
    end
  end

  def import_struc_comments seq, seq_node
    (seq_node/'/INSDSeq_struc-comments/INSDStrucComment').each do |comment_node|
      comment = seq.struc_comments.create!(
        name: (comment_node/'/INSDStrucComment_name').inner_html
      )
      import_struc_comment_items comment, comment_node
    end
  end

  def import_struc_comment_items comment, comment_node
    (comment_node/'/INSDStrucComment_items/INSDStrucCommentItem').each do |item_node|
      comment.items.create!(
        tag: (comment_node/'/INSDStrucCommentItem_tag').inner_html,
        value: (comment_node/'/INSDStrucCommentItem_value').inner_html,
        url: (comment_node/'/INSDStrucCommentItem_url').inner_html
      )
    end
  end

  def import_comments seq, seq_node
    (seq_node/'/INSDSeq_comment-set/INSDComment').each do |comment_node|
      comment = seq.comment_set.create!(
        type: (comment_node/'/INSDComment_type').inner_html
      )
      import_comment_paragraphs comment, comment_node
    end
  end

  def import_comment_paragraphs comment, comment_node
    (comment_node/'/INSDComment_paragraphs/INSDCommentParagraph').each do |paragraph_node|
      paragraph = comment.paragraphs.create!
      import_paragraph_items paragraph, paragraph_node
    end
  end

  def import_paragraph_items paragraph, paragraph_node
    (paragraph_node/'/INSDCommentParagraph_items/INSDCommentItem').each do |item_node|
      paragraph.items.create!(
        value: (item_node/'/INSDCommentItem_value').inner_html,
        url:   (item_node/'/INSDCommentItem_url').inner_html
      )
    end
  end

  def import_other_seqids seq, seq_node
    (seq_node/'/INSDSeq_other-seqids/INSDSeqid').each do |other_seqid_node|
      seq.other_seqids.create!(
        seqid: other_seqid_node.inner_html
      )
    end
  end

  def import_secondary_accns seq, seq_node
    (seq_node/'/INSDSeq_secondary-accessions/INSDSecondary-accn').each do |secondary_accn_node|
      seq.secondary_accessions.create!(
        value: secondary_accn_node.inner_html
      )
    end
  end

  def import_keywords seq, seq_node
    (seq_node/'/INSDSeq_keywords/INSDKeyword').each do |keyword_node|
      seq.keywords.create!(
        value: keyword_node.inner_html
      )
    end
  end

  def import_references seq, seq_node
    (seq_node/'/INSDSeq_references/INSDReference').each do |reference_node|
      reference = seq.references.create!(
        reference:  (reference_node/'/INSDReference_reference').inner_html,
        position:   (reference_node/'/INSDReference_position').inner_html,
        consortium: (reference_node/'/INSDReference_consortium').inner_html,
        title:      (reference_node/'/INSDReference_title').inner_html,
        journal:    (reference_node/'/INSDReference_journal').inner_html,
        xref_pk:    xref(reference_node/'/INSDReference_xref/INSDXref').pk,
        pubmed:     (reference_node/'/INSDReference_pubmed').inner_html,
        remark:     (reference_node/'/INSDReference_remark').inner_html
      )
      import_authors reference, reference_node
    end
  end

  def import_authors reference, reference_node
    (reference_node/'/INSDReference_authors/INSDAuthor').each do |author_node|
      
      ( (author = Insd::Author.find_by_value(author_node.inner_html)) && # FIXME: needs to be project.authors
        (reference.authors << author)
      ) ||
      reference.authors.create!(
        value: author_node.inner_html
      )
    end
  end

  def xref xref_node
    Insd::Xref.create!(
      dbname: (xref_node/'/INSDXref_dbname').inner_html,
      id:     (xref_node/'/INSDXref_id').inner_html
    )
  end
end
