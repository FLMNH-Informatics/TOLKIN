# == Schema Information
# Schema version: 20090605174655
#
# Table name: matrices
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  project_id  :integer
#  creator_id  :integer
#  updator_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  parent_id   :integer(8)
#  backup      :boolean
#
require 'branched_versioned'
module Morphology
    class Matrix::Checkpoint < ActiveRecord::Base
      self.table_name = 'matrices'
      include BranchedVersioned

      acts_as_tree :order => :name
      has_many :otus, :through => :matrices_otus, :order => "matrices_otus.position"
      has_many :matrices_otus, :class_name => "Morphology::MatricesOtu", :foreign_key => 'matrix_id', :order => "matrices_otus.position"
      has_many :characters, :through => :characters_matrices, :class_name => "Morphology::Character", :order => "characters_matrices.position", :readonly => false
      has_many :characters_matrices, :class_name => "Morphology::CharactersMatrix", :foreign_key => 'matrix_id'
      has_many :state_codings, :class_name => "Morphology::StateCoding", :foreign_key => 'matrix_id'
      has_many :codings, :class_name => "Morphology::StateCoding", :foreign_key => 'matrix_id'
      belongs_to :creator, :class_name => "User"
      belongs_to :updator, :class_name => "User"
      belongs_to :project
      has_one :branch_item, :as => :item, :class_name => 'Matrix::BranchItem'
      has_one :matrix_detail, :class_name => "Morphology::MatrixDetail"
      has_many :morphology_matrices_otu_groups, :class_name => "Morphology::Matrix::MorphologyMatricesOtuGroups" , :foreign_key => "matrix_checkpoint_id"


      def address_on_branch(branch)
        branch_position = Matrix::BranchItemsBranch.find_by_branch_id_and_branch_item_id(branch.id, branch_item.id).position
        Matrix::Address.from_branch_info(branch, branch_position)
      end

      alias_method :x_items, :characters
      alias_method :y_items, :otus
      alias_method :cells, :codings

      def detail
        matrix_detail
      end

    #  def self.codings_to_hash(chrs, otus, state_codings)
    #    return state_codings if state_codings.class == Hash # don't process codings if they are already in hash form
    #    #matrix_hash = Hash.new
    #    matrix_hash = Morphology::CodingsContainer.for_codings(state_codings)
    #    #otus.each { |i| matrix_hash[i.id] = {} }
    #
    #    return matrix_hash
    #  end

      def to_param
        "#{self.object_history.id}-#{self.branch.branch_number}-#{self.branch_position}"
      end

      # retrieve the x-, y-, and cell contents of a matrix in that order
      def get_contents(options = { })
        codings = [ ]
        matrix_id = self.id.to_s
        if options[:group_id]
           where_cond = "AND otu_groups.id =" + options[:group_id]
        else
          where_cond = ""
        end
    #    join_conditions = "LEFT JOIN otu_groups_otus ogo ON (ogo.otu_id=otus.id) LEFT JOIN matrices_otu_groups mog ON (mog.matrix_checkpoint_id= "+ id.to_s+ " AND mog.otu_group_id=ogo.otu_group_id) LEFT JOIN v_users creator ON (otus.creator_id = creator.id)"
        if options[:page]
          characters = self.characters.find(:all, :include => :creator).paginate(:page => options[:page], :per_page => 15)
                    #otus =  self.otus.all(select: 'otus.*, mog.color as color', joins: join_conditions, conditions: where_conditions ).to_a
                    #is_current = t -> dosen't work as matrices_otus and otus are linked by ids and not by timeline

          if options[:group_id]
            chkpt_sql_query = "SELECT DISTINCT ON (ogo.otu_id) otus.*, mog.color FROM otu_groups
                      INNER JOIN matrices_otu_groups mog ON (mog.matrix_checkpoint_id=#{matrix_id} AND otu_groups.id = mog.otu_group_id)
                      INNER JOIN otu_groups_otus ogo ON (ogo.otu_group_id = otu_groups.id #{where_cond})
                      INNER JOIN otus ON otus.id = ogo.otu_id"
             otus =  Otu.find_by_sql(%{#{chkpt_sql_query}})
          else
             chkpt_sql_query = "SELECT otus.*, otug.color FROM matrices
                    INNER JOIN matrices_otus mo ON mo.matrix_id = matrices.id
                    INNER JOIN otus ON mo.otu_id = otus.id
                    LEFT JOIN
                    (	SELECT DISTINCT ON (ogo.otu_id) otu_groups.id AS otu_group_id, ogo.otu_id AS otu_id, mog.color FROM otu_groups
                      INNER JOIN matrices_otu_groups mog ON (mog.matrix_checkpoint_id=#{matrix_id} AND otu_groups.id = mog.otu_group_id)
                      INNER JOIN otu_groups_otus ogo ON (ogo.otu_group_id = otu_groups.id #{where_cond})
                    ) AS otug ON (otug.otu_id = otus.id)
                    WHERE matrices.id=#{matrix_id}"
                   otus =  Otu.find_by_sql(%{#{chkpt_sql_query}})
          end

          chr_id_condition = characters.empty? ? nil : "character_id in (" + characters.collect{ |chr| chr.id.to_s }.join(",") + ")"
           if options[:query_for_codings]
            options[:query_for_codings][:conditions] = options[:query_for_codings][:conditions] + " AND " + chr_id_condition
            codings = self.codings.find(:all, options[:query_for_codings]).to_a unless options[:retrieve_cells] == false
          else
            codings = self.codings.find(:all, :conditions => chr_id_condition).to_a unless options[:retrieve_cells] == false
          end
        else
          characters = self.characters.find(:all, :include => :creator).to_a
             if options[:group_id]
            chkpt_sql_query = "SELECT DISTINCT ON (ogo.otu_id) otus.*, mog.color FROM otu_groups
                      INNER JOIN matrices_otu_groups mog ON (mog.matrix_checkpoint_id=#{matrix_id} AND otu_groups.id = mog.otu_group_id)
                      INNER JOIN otu_groups_otus ogo ON (ogo.otu_group_id = otu_groups.id #{where_cond})
                      INNER JOIN otus ON otus.id = ogo.otu_id"
             otus =  Otu.find_by_sql(%{#{chkpt_sql_query}})
          else
             chkpt_sql_query = "SELECT otus.*, otug.color FROM matrices
                    INNER JOIN matrices_otus mo ON mo.matrix_id = matrices.id
                    INNER JOIN otus ON mo.otu_id = otus.id
                    LEFT JOIN
                    (	SELECT DISTINCT ON (ogo.otu_id) otu_groups.id AS otu_group_id, ogo.otu_id AS otu_id, mog.color FROM otu_groups
                      INNER JOIN matrices_otu_groups mog ON (mog.matrix_checkpoint_id=#{matrix_id} AND otu_groups.id = mog.otu_group_id)
                      INNER JOIN otu_groups_otus ogo ON (ogo.otu_group_id = otu_groups.id #{where_cond})
                    ) AS otug ON (otug.otu_id = otus.id)
                    WHERE matrices.id=#{matrix_id}"
                   otus =  Otu.find_by_sql(%{#{chkpt_sql_query}})
          end
          chr_id_condition = characters.empty? ? nil : "character_id in (" + characters.collect{ |chr| chr.id.to_s }.join(",") + ")"
          if options[:query_for_codings]
            options[:query_for_codings][:conditions] = options[:query_for_codings][:conditions] + " AND " + chr_id_condition
            codings = self.codings.find(:all, options[:query_for_codings]).to_a unless options[:retrieve_cells] == false
          else
            codings = self.codings.where(chr_id_condition).to_a unless options[:retrieve_cells] == false
          end
        end
        [ characters, otus, codings ]
      end

      def self.get_states_for_tooltip(chrs)
        tooltiphash = Hash.new {|hash, key| hash[key] = [ ]}; # initialize space for each new character id to an empty array to hold tooltips by state_num

        unless chrs.empty?
          chr_states = Morphology::ChrState.find(:all, :conditions => ["character_id in (#{chrs.join(',')})"])
          chr_states.each { |cs| tooltiphash[cs.character_id][cs.state.to_i] = cs.name }
    #        if tooltiphash[cs.character_id]
    #          tooltiphash[cs.character_id] << cs.state + " : " + cs.name + " &lt;br&gt;"
    #        else
    #          tooltiphash[cs.character_id] = cs.state + " : " + cs.name + " &lt;br&gt;"
    #        end
        end

        tooltiphash
      end

      def mark_codings_record(chr_id, otu_id, flag)
        query = ""
        query = "UPDATE state_codings SET updated_flag" + flag.to_s
        query << " WHERE MATRIX_ID=" + self.id.to_s
        query << " AND CHARACTER_ID=" + chr_id.to_s
        query << " AND OTU_ID=" + otu_id.to_s

        con = ActiveRecord::Base.connection();
        con.execute "SET autocommit=1";
        con.execute(query)
      end

      def self.status
        ['incomplete', 'complete', 'problem']
        #{ 'notstarted' => 'Not Started', 'started' => 'Started', 'completed' => 'Completed',  'reviewed' => 'Reviewed'}
      end

      def self.export_types
        ['Nexus File', 'NEXML']
      end

      def new_join_table_record(character_id, otu_id)
        new_record_hash = { 'character_id' => character_id, 'otu_id' => otu_id, 'status' => 'incomplete' }
        chrs_mxes_otu = self.state_codings.new(new_record_hash)
        success = chrs_mxes_otu.save
        return success
      end

      def remove_join_table_records(otu_id, character_id)
        success = true
        unless otu_id.nil?
          chrs_mxes_otus = self.state_codings.find_all_by_otu_id(otu_id)
          chrs_mxes_otus.each { |cmo|
            success = cmo.destroy
          }
        end

        unless character_id.nil?
          chrs_mxes_otus = self.state_codings.find_all_by_character_id(character_id)
          chrs_mxes_otus.each { |cmo|
            print "helkolasldfasdf"
            success = cmo.destroy
          }
        end

        return success
      end

      #merge method, merge this matix with the matrix_two
      def merge_with_matrix(matrix_one, matrix_two)
        success = true

        # add new characters / otus to parent matrix that were added to the child matrix
        extra_otus = matrix_one.otus.find(:all, :conditions => [ "otus.id not in (#{matrix_two.otus.collect {|o| o.id}.join(',')})"])
        extra_otus.each do |otu|
          matrix_two.otus << otu unless matrix_two.otus.include?(otu)
          #update_otus_in_join_table(otu)
        end

        extra_characters = matrix_one.characters.find(:all, :conditions => [ "characters.id not in (#{matrix_two.characters.collect {|c| c.id}.join(',')})"])
        extra_characters.each do |chr|
          if !matrix_two.characters.include?(chr)
            matrix_two.characters << chr
          end
          #update_chrs_in_join_table(chr)
        end
        # update the join table for state codings
        chrs_mxes_otus = matrix_one.state_codings.find(:all)#, :conditions => "updated_flag = true")
        #chrs_mxes_otus << matrix_one.state_codings.find(:all, :conditions => "character_id in (#{extra_characters.collect{|c| c.id}.join(',')})") if !extra_characters.empty?
        #chrs_mxes_otus << matrix_one.state_codings.find(:all, :conditions => "otu_id in (#{extra_otus.collect {|o| o.id}.join(',')})") if !extra_otus.empty?
        #chrs_mxes_otus.flatten!
        updated_fields = Hash.new
        unless chrs_mxes_otus.nil?
          chrs_mxes_otus.each { |cmo|
            parent_cmo = matrix_two.state_codings.find(:all, :conditions => ["character_id = #{cmo.character_id} and otu_id = #{cmo.otu_id}"])
            if !parent_cmo.nil? && !parent_cmo.empty?
              if cmo.codings != parent_cmo[0].codings or cmo.status != parent_cmo[0].status
                updated_fields[:codings]= cmo.codings
                updated_fields[:status] = cmo.status
                parent_cmo.each { |i| i.update_attributes(updated_fields)  }
              end
            else
              new_parent_cmo = matrix_two.state_codings.new(:otu_id => cmo.otu_id, :character_id => cmo.character_id, :codings => cmo.codings, :status => cmo.status, :updated_flag =>true)
              new_parent_cmo.save!
            end
            #cmo.update_attributes(:updated_flag => false)
          }
        end
        return success
      end

      # creates a new matrix that is identical to the current matrix in characters,
      # otus, and state_codings.  if options[:full_copy] is true, then timestamps and
      # user-stamps are copied as well.  returns the copy created
      def create_copy(options = {})

        Morphology::Matrix::Checkpoint.transaction do
          # copy matrix details (including timestamps if full_copy option given)
          if options[:full_copy]
            Morphology::Matrix::Checkpoint.record_timestamps = false
          end
          @new_matrix = Morphology::Matrix::Checkpoint.create(:creator => creator, :created_at => created_at)
          #Morphology::MatrixDetail.create(
          #  :matrix => @new_matrix,
          #  :updater => detail.updater,
          #  :updated_at => detail.updated_at,
          #  :name => detail.name,
          #  :description => detail.description
          #)
          if options[:full_copy]
            Morphology::Matrix::Checkpoint.record_timestamps = true
          end

          # copy characters and otus
          characters.each { |chr| @new_matrix.characters << chr }
          otus.each { |otu| @new_matrix.otus << otu }

          #Copy state codings info
          #state_codings = state_codings
          # copy every field including timestamps only if full_copy option
          # given
          Morphology::StateCoding.record_timestamps = false if options[:full_copy]
          state_codings.each { |cmo|
            new_cmo = @new_matrix.state_codings.new
            new_cmo.character_id = cmo.character_id
            new_cmo.otu_id = cmo.otu_id
            new_cmo.status = cmo.status
            new_cmo.codings = cmo.codings
            if options[:full_copy]
              new_cmo.created_at = cmo.created_at
              new_cmo.updated_at = cmo.updated_at
              new_cmo.creator = cmo.creator
              new_cmo.updater = cmo.updater
            end
            new_cmo.save
          }
          Morphology::StateCoding.record_timestamps = true if options[:full_copy]
        end

        return @new_matrix


      end

      # method that takes an array of matrices, filters them, and returns only those
      # matrices residing at the max positions of their main branches
      def self.at_max_branch_positions(matrices)
        matrices.collect do |matrix|
          matrix if matrix.try(:branch) && !matrix.branch.deleted_at && matrix.branch_position == matrix.branch.max_position
        end.compact
      end

      # perform a merging between two matrix versions.  raise an exception if matrices cannot be merged
      def self.merge(from_matrix, to_matrix, options = { })
#        debugger
        merger = Morphology::Matrix::Merger.new
        merger.merge_matrices(from_matrix, to_matrix, options)
      end
  end
end
