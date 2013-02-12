# class used to merge one virtual matrix with another virtual matrix
class Morphology::Matrix::Merger
  def merge_matrices(from_matrix, to_matrix, options = {})
    ::Matrix::Changeset.transaction do
      options[:shared_history] = ( from_matrix.history == to_matrix.history ) ? true : false
      @changeset = ::Matrix::Changeset.create!(:changeset_number => to_matrix.version_number, :branch => to_matrix.branch)
      otu_translation = find_id_translation(from_matrix.otus, to_matrix.otus)
      chr_translation = find_id_translation(from_matrix.characters, to_matrix.characters)
      otu_translation = merge_translated(from_matrix.otus, to_matrix.otus, otu_translation, options[:shared_history])
      chr_translation = merge_translated(from_matrix.characters, to_matrix.characters, chr_translation, options[:shared_history])
      merge_codings(from_matrix.codings, to_matrix.codings, otu_translation, chr_translation, options)
      @changeset.commit(:new_branch => options[:new_branch])
    end
  end

  private

  def find_id_translation(from_items, to_items)
    translation = { }
    from_items.each do |from_item|
      to_item_match = from_item.equivalent_in(to_items) # pass changeset for adding new chr states to matches - ugly : should be a better way to account for additional chr states on chrs being matched
      to_item_match ? translation.merge!({ from_item.id => to_item_match.id }) : translation.merge!({ from_item.id => nil })
    end
    translation
  end

  # merge characters or otus with id translation hash for analogues
  def merge_translated(from_items, to_items, id_translation, have_shared_history)
    from_items.each do |from_item|
      if id_translation[from_item.id].nil?
        new_version = have_shared_history ?  from_item : from_item.create_clone
        id_translation[from_item.id] = new_version.id
        @changeset.items.create!(:change_type => ChangeTypes::ADD, :new_version => new_version)
      end
    end
    id_translation
  end

  # codings must be in a nested hash indexed by otu and character
  def merge_codings(from_codings, to_codings, otu_translation, chr_translation, options = { })
    # unhash the codings and perform translation for each one
    from_codings.to_a.each do |from_coding|
      translated_otu_id = otu_translation[from_coding.otu.id]
      translated_chr_id = chr_translation[from_coding.character.id]
      to_coding = to_codings.fetch(translated_chr_id, translated_otu_id)
      # only overwrite to codings with from codings in certain conditions
      if (!options[:reverse_overwrite] && (!to_coding || to_coding.codings != from_coding.codings || to_coding.status != from_coding.status)) ||
         (options[:reverse_overwrite] && !to_coding)
        from_coding = from_coding.clone
        from_coding.matrix = nil
        from_coding.otu_id, from_coding.character_id = translated_otu_id, translated_chr_id
        from_coding.save!
        @changeset.items.create!(:change_type => ChangeTypes::MODIFY, :old_version => to_coding, :new_version => from_coding)
      end
    end
  end
end
