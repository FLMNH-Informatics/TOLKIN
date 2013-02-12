class Morphology::Matrix < ActiveRecord::Base
  include GenericSearch

  has_many :timelines,
           :class_name  => 'Morphology::Matrix::Timeline',
           :foreign_key => 'matrix_id',
           :order => 'updated_at'

  belongs_to :project

  self.table_name = 'morphology_matrices'

end







## matrix object which does not have a presence in the database
##No longer in use
#class Morphology::Matrix
#
#  X_ITEM_CLASS  = "Morphology::Character"
#  X_ITEM_NAME   = "character"
#  Y_ITEM_CLASS  = "Otu"
#  Y_ITEM_NAME   = "otu"
#  CELL_CLASS    = "Morphology::StateCoding"
#  CELL_NAME     = "coding"
#
#  include MatrixTyped
#
#  def self.get_filters
#    Matrix::Branch.get_filters
#  end
#
#  @@accessible_attribute_names = :characters, :otus, :address
#  attr_accessor(*@@accessible_attribute_names)
#  attr_reader :retrieve_cells
#
#  def id
#    address.to_s
#  end
#
#  def to_param
#    address.to_s
#  end
#
#  def initialize(options = {})
#    @retrieve_cells = options[:retrieve_cells] ? true : false
#    @codings = IndexedOnTwoDimensionsArray.new :character, :otu, options[:codings] if options[:codings]
#    @@accessible_attribute_names.each do |attribute|
#      instance_variable_set("@#{attribute.to_s}", options[attribute])
#    end
#  end
#
#  def codings
#    @codings
#  end
#
#  def create_checkpoint
#    @new_matrix = create_copy
#    branch_item = Matrix::BranchItem.create(:item => @new_matrix)
#    Matrix::BranchItemsBranch.create(:branch_item => branch_item, :branch => branch, :position => version_number)
#    @new_matrix
#  end
#
#  def create_copy(options)
#    Morphology::Matrix::Checkpoint.transaction do
#      # copy matrix details (including timestamps if full_copy option given)
#      @new_matrix = Morphology::Matrix::Checkpoint.create!
#
#      # copy characters and otus
#      #@new_matrix.characters << characters.uniq
#      #BULK INSERT CHARACTERS (MUCH FASTER)
#      unless characters.empty?
#        insert_characters = "INSERT into characters_matrices (character_id, matrix_id, "
#        insert_characters << "position, updated, new_flag, marked_for_deletion) VALUES "
#        characters.each_with_index do |char, index|
#          insert_characters << "('#{char.id}', '#{@new_matrix.id}', #{index+1}, NULL, NULL, NULL),"
#          end
#        ActiveRecord::Base.connection.execute(insert_characters.chomp(","))
#      end
#
##      @new_matrix.otus << otus.uniq
#      #BULK INSERT OTUS (MUCH FASTER)
#      unless otus.empty?
#        insert_otus = "INSERT into matrices_otus (otu_id, matrix_id, "
#        insert_otus << "position, new_flag, marked_for_deletion) VALUES "
#        otus.each_with_index do |otu, index|
#          insert_otus << "('#{otu.id}', '#{@new_matrix.id}', #{index+1}, NULL, NULL),"
#        end
#        ActiveRecord::Base.connection.execute(insert_otus.chomp(","))
#      end
#      # turn hash-form of codings into flat array of codings for copying purposes
##      beginning_time = Time.now
#      #one big insert statement instead of multiple inserts (SLOW)
#      @statecodings = (options[:revert] == true) ? options[:matrix_codings] : codings
#      unless @statecodings.to_a.empty?
#        insert_string = "INSERT into state_codings (character_id, codings, copied_from_id, created_at, creator_id, matrix_id, "
#        insert_string << "otu_id, project_id, status, updated_at, updated_flag, updater_id) VALUES "
#        @statecodings.to_a.each do |coding|
#          insert_string << "(#{coding.character_id}, '#{coding.codings}', NULL, "
#          insert_string << "'#{coding.created_at}', #{options[:current_user].nil? ? coding.creator_id : options[:current_user]}, #{@new_matrix.id}, "
#          insert_string << "#{coding.otu_id}, #{@new_matrix.project_id}, '#{coding.status}', "
#          insert_string << "'#{Time.now}', NULL, NULL),"
#  #        new_coding = coding.clone
#  #        new_coding.matrix_id = @new_matrix.id
#  #        new_coding.save(:validate => false)
#  #        new_coding.images << coding.images
#        end
#        ActiveRecord::Base.connection.execute(insert_string.chomp(","))
#      end
#      @new_matrix
#    end
#  end
#
#  #@Ram
#  #This function generates the nexus file and writes it to a temporary location
#  #in the disk.
#  #TODO: Mechanism to clean the old generated nexus files.  Perhaps a script to
#  #monitor the directory and delete or create a ui on the admin console and
#  #have the user trigger the deletion
#  def export_to_nexus(file_name)
#
#
#    filename = "#{RAILS_ROOT}/public/nexus/#{file_name}"
#    codings_hash = {}
#    #Nexus file has a Taxa block, Characters Block and Matrix Block with in characters block
#    #This procedure writes these blocks based on the data in the tables
#
#    File.open(filename,  "w") do |file|
#      file.print "#NEXUS\n\n"
#      file.print "[NEXUS FILE GENERATED BY TOLKIN]\n\n"
#
#      @file = file
#
#      write_taxa_block
#
#      otus.each { |otu| codings_hash[otu.id] = {} } # create space for filling in codings hash
#
#      #Write Characters Block
#      #Loop through characters, and each state for every character and write them to file
#      file.print "BEGIN CHARACTERS;\n"
#      file.print "DIMENSIONS NCHAR=#{self.characters.size.to_s};\n"
#      file.print "FORMAT GAP=- MISSING=? SYMBOLS= \" 0 1 2 3 4 5 6 7 8 9\";\n\n";
#
#      write_char_state_labels
#
#      #Matrix Block
#      file.print "MATRIX\n\n"
#
#      #max_tabs = (max_len_otu_name / 4)+ 1
#      #Matrix block has Otu Name followed by codings in the same order
#      #in which characters were written previously
#
#      #Create the hash with codings.  For ease of processing.
#
#      codings_array = codings.to_a
#      unless codings_array.nil?
#        codings_array.each { |i|
#          codings_hash[i.otu_id][i.character_id] = i.codings
#        }
#      end
#
#      self.otus.each { |otu|
#        curr_line = ""
#        otu_name = otu.name.humanize.gsub(/\s/, "_")
#        otu_name = (otu_name =~ /^[\w\s]+$/)? otu_name : "'#{otu_name}'" # put title in quotes if it contains special characters
#        curr_line << otu_name
#
#        #Calculate the number of tabs required after OTU name
#        #n_tabs = max_tabs - (otu.name.length/4) + 1
#        #n_tabs.times {
#        curr_line << "\n"
#        #}
#        #If there is no coding print a "-"
#        #If only one print it as such
#        #If more than one, print them with in bracess
#        self.characters.each { |chr|
#          coding = codings_hash[otu.id][chr.id]
#
#          if coding.nil? or coding.blank?
#            curr_line << "-"
#          else
#
#            if coding.length > 1
#              tmp_s = coding.to_s
#              #mp_s = tmp_s.gsub(/ /, ',')
#              tmp_s = "{" + tmp_s.gsub(/ /, '') + "}"
#              curr_line << tmp_s
#            else
#              curr_line << coding
#            end
#
#          end
#        }
#        file.print "#{curr_line}\n"
#      }
#
#      file.print(";\nEND;\n")
#    end
#  end
#
#  #def object_history
#  #  address.try(:object_history)
#  #end
#
#  #def history
#  #  object_history
#  #end
#  #
#  #def branch_item
#  #  branch.try(:branch_items_branches) ? branch.branch_items_branches.find_by_position(version_number).try(:branch_item) : nil
#  #end
#  #
#  #def branch_position
#  #  address.try(:branch_position)
#  #end
#  #
#  #def checkpoint
#  #  branch_item.try(:item)
#  #end
#  #
#  #def x_items
#  #  characters
#  #end
#  #
#  #def x_items= value
#  #  @characters = value
#  #end
#  #
#  #def y_items
#  #  otus
#  #end
#  #
#  #def y_items= value
#  #  @otus = value
#  #end
#  #
#  #def cells
#  #  codings
#  #end
#  #
#  #def cells= value
#  #  @codings = IndexedOnTwoDimensionsArray.new :character, :otu, value
#  #end
#  #
#  #def suggested_submatrix_name
#  #   branches_like = branch.project.branches.find_by_sql("select * from branches where project_id = 73 and item_type = 'Morphology::Matrix' and name ILIKE '#{name}-sub-%'")
#  #   number = 1
#  #   branches_like.each do |branch|
#  #      temp = branch.name["#{name}-sub-".size, branch.name.size].to_i
#  #      debugger
#  #      number = temp if number < temp
#  #      number += 1 if(number == temp && branch.name["#{name}-sub-".size, branch.name.size] == number.to_s)
#  #   end
#  #   name+"-sub-"+number.to_s
#  #end
#    protected
#
#  def write_taxa_block
#    @file.print "BEGIN TAXA;\n"
#    @file.print "DIMENSIONS NTAX=#{self.otus.size.to_s};\n\n"
#    @file.print "TAXLABELS\n\n"
#
#    otus = self.otus
#    position = 0
#    otu_names = otus.collect do |otu|
#      otu_name = otu.name.humanize.gsub(/\s/, "_")
#      otu_name = (otu_name =~ /^[\w\s]+$/)? otu_name : "'#{otu_name}'" # put title in quotes if it contains special characters
#      "\t[#{position+=1}]\t#{otu_name}"
#    end
#    @file.print otu_names.join("\n")
#    @file.print("\n;\nEND;\n\n")
#  end
#
#  def write_char_state_labels
#    @file.print "CHARSTATELABELS\n\n"
#    characters = self.characters
#    position = 0
#    chrs_with_states = characters.collect do |chr|
#      chr_name = chr.name.humanize.gsub(/\s/, "_")
#      chr_name = (chr_name =~ /^[\w\s]+$/)? chr_name : "'#{chr_name}'" # put title in quotes if it contains special characters
#      chr_state_str = "\t#{position+=1}\t#{chr_name}"
#      unless chr.chr_states.nil?
#        chr_state_str << " / "
#        chr_state_names = chr.chr_states.collect do |chr_state|
#          chr_state_name = chr_state.name.humanize.gsub(/\s/, "_")
#          (chr_state_name =~ /^[\w\s]+$/ || chr_state_name.empty?)? chr_state_name : "'#{chr_state_name}'"
#        end
#        chr_state_str << chr_state_names.join(" ")
#      end
#    end
#    @file.print chrs_with_states.join(",\n")
#    @file.print "\n;\n\n"
#  end
#end