class NexusDataset < ActiveRecord::Base

  belongs_to :project

  belongs_to  :creator, :class_name => "Person", :foreign_key => "creator_id"
  belongs_to  :updator, :class_name => "Person", :foreign_key => "updator_id"

#  has_attachment  :content_type => [ 'text/plain', 'text/plain charset=us-ascii' ],
#    :storage => :file_system,
#    :max_size => 20.megabytes,
#    :path_prefix => "public/files/datasets"
#
#  validates_as_attachment



  def nexus_file(tmpfile)
    NexusParser.parse_text(self.file_data(tmpfile))
  end

  def nexus_to_db(user, project, matrix_name,tempfile, options = {})
    @user = user
    @project = project
    @connection = ActiveRecord::Base.connection

    @nexus_file = nexus_file(tempfile)

    ##TODO: Make sure to enable transaction
    Morphology::Matrix.transaction do
      #Create the matrix
      #@matrix = Morphology::Matrix::Checkpoint.create!
      #object_history = Matrix::History.create!(:item_type => "Morphology::Matrix")
      #branch_item = Matrix::BranchItem.create!(:item => @matrix, :project_id => @project.project_id)
      #branch = object_history.branches.create!(:branch_number => 1, :name => matrix_name, :parent_id => options[:parent_id], :item_type => 'Morphology::Matrix', :project_id => @project.project_id)
      #Matrix::BranchItemsBranch.create!(:branch_item => branch_item, :branch => branch, :position => 1, :project_id => @project.project_id)

      @matrix = Morphology::Matrix.create!(:name => matrix_name)
      @timeline = Morphology::Matrix::Timeline.create!(:matrix_id => @matrix.id)

      process_otus
      process_characters
      process_codings
    end

    @timeline
  end

  def file_data(tmpfile)
    #File.read("#{RAILS_ROOT}/public#{self.filename}")
    File.read(tmpfile)
  end

  private

  def process_codings
    codings_str = @nexus_file.codings[0..@nexus_file.taxa.size].collect.with_index { |y, i| # y is a rowvector of NexusFile::Coding
      y.collect.with_index { |x, j| # x is a NexusFile::Coding
        coding = x.states.reject{|state| state.nil? || state == '-' }.join(' ')
        coding.blank? ?
          "" :
          "(#{@timeline.id}, #{@chrs[j]['id']}, #{@otus[i]['id']}, '#{coding}', now(), true, #{@user.id}, 'complete')"
      }.reject{|str| str.blank? }.join(',') # don't create state_codings for empty spaces
    }.reject{|str| str.blank? }.join(',') # don't mark anything for empty rows

    unless codings_str.blank?
      @connection.execute %{
      INSERT INTO morphology_matrix_cells (timeline_id, character_id, otu_id, state_codings, create_date, is_active, creator_id, status) VALUES #{codings_str} }
    end
  end

  def process_otus
    otus_to_search = @nexus_file.taxa
    #names_to_search_string = otus_to_search.collect { |taxon| "'#{taxon.name.downcase}'" }.join(',')
    names_to_search_string = otus_to_search.collect { |taxon| taxon.name.downcase }.join(%{,})
    #otus_found = @connection.select_all("SELECT id, name FROM otus WHERE project_id = #{@project.id} AND is_current = TRUE AND lower(name) IN (#{names_to_search_string})")
    otus_found = Otu.where('project_id = ? and is_current = TRUE and lower(name) in (?)', @project.id, otus_to_search.collect { |taxon| taxon.name.downcase })
    otus_found_hash = otus_found.inject({}) { |hash, otu| hash[otu['name'].downcase] = otu; hash }
    otus_not_to_add, otus_to_add = otus_to_search.partition { |otu| otu.id = otus_found_hash[otu.name.downcase].try(:[], 'id') }

    unless otus_to_add.empty?
      main_otus_added = @connection.select_values %{
        INSERT INTO otus (creator_id, updator_id, created_at, updated_at, project_id, name, original_position)
          VALUES #{ otus_to_add.collect.with_index{ |otu, idx| "(#{@user.id}, #{@user.id}, now(), now(), #{@project.id}, '#{otu.name}', #{otu.index})" }.join(',') }
          RETURNING id
      }
      otus_to_add.each { |otu| otu.id = main_otus_added.shift }
    else
      main_otus_added = []
    end

    @connection.execute %{
      INSERT INTO morphology_matrices_otus (otu_id, timeline_id, position, create_date)
        VALUES #{otus_to_search.collect {|otu| "(#{otu.id}, #{@timeline.id}, #{otu.index}, now())"}.join(',') }
    }
    @timeline.reload
    @otus = @timeline.otus
  end



  def process_characters
    chrs_to_search = @nexus_file.characters
    names_to_search_string = chrs_to_search.collect { |chr| "'#{chr.name.downcase}'" }.join(',')
    chrs_found = @connection.select_all %{ SELECT id, name FROM characters WHERE project_id = #{@project.id} AND is_current = TRUE AND lower(name) IN (#{names_to_search_string}) }
    chrs_found_hash = chrs_found.inject(Hash.new{|hash, key| hash[key] = [] }) { |hash, chr| hash[chr['name'].downcase].push(chr); hash }
    states_found = chrs_found.empty? ? [] : @connection.select_all(%{ SELECT name, character_id FROM chr_states WHERE character_id IN (#{chrs_found.collect{|chr| chr['id'] }.join(',')}) ORDER BY character_id, state })
    state_names_found_hash = states_found.inject(Hash.new{|hash, key| hash[key] = [] }) { |hash, state| hash[state['character_id'].to_i].push(state['name']); hash }
    chrs_not_to_add, chrs_to_add = chrs_to_search.partition do |chr|
      (index = chrs_found_hash[chr.name.downcase].index { |found_chr|
        chr.states.all_with_index? do |state, index|
          state_names_found_hash[found_chr['id'].to_i][index].try(:casecmp, state.name) == 0 # and the names of the found characters states all match up in the same locations
        end
      }) && (chr.id = chrs_found_hash[chr.name.downcase][index]['id'].to_i)
    end

    unless chrs_to_add.empty?
      main_chrs_added = @connection.select_values %{
        INSERT INTO characters (creator_id, updator_id, created_at, updated_at, project_id, name, original_position)
          VALUES #{ chrs_to_add.collect.with_index{ |chr, idx| "(#{@user.id}, #{@user.id}, now(), now(), #{@project.id}, '#{chr.name}', #{chr.index})" }.join(',') }
          RETURNING id
      }
      chrs_to_add.each { |chr| chr.id = main_chrs_added.shift }

      main_chr_states_to_add = chrs_to_add.collect { |chr|
        chr.states.collect.with_index { |state, idx|
          "(#{@user.id}, #{@user.id}, now(), now(), #{chr.id}, '#{state.name}', '#{idx}')"
        }.join(',')
      }.reject{|str| str.blank? }.join(',') # if no character states for a character don't create an empty space
      unless main_chr_states_to_add.blank?
        @connection.execute %{ INSERT INTO chr_states (creator_id, updator_id, created_at, updated_at, character_id, name, state) VALUES #{main_chr_states_to_add} }
      end
    else
      main_chrs_added = []
    end

    @connection.execute %{
      INSERT INTO morphology_matrices_characters (character_id, timeline_id, position, create_date)
        VALUES #{chrs_to_search.collect {|chr| "(#{chr.id}, #{@timeline.id}, #{chr.index}, now())"}.join(',') }
    }

    @timeline.reload
    @chrs = @timeline.characters
  end
end
