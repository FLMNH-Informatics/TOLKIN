class Morphology::Matrix::Timeline < ActiveRecord::Base

  has_many :matrices_characters,
           :class_name  => "Morphology::Matrix::MatricesCharacters",
           :foreign_key => "timeline_id",
           :order       => "position"

  has_many :characters,
           :through    => :matrices_characters,
           :class_name => "Morphology::Character"

  has_many :matrices_otus,
           :class_name  => "Morphology::Matrix::MatricesOtus",
           :foreign_key => "timeline_id"

  has_many :otus,
           :through => :matrices_otus

  has_many :cells,
           :class_name  => "Morphology::Matrix::Cell",
           :foreign_key => "timeline_id",
           :conditions  => {:is_active => true}

  belongs_to  :matrix,
              :class_name => "Morphology::Matrix",
              :foreign_key => "matrix_id"

  #belongs_to :project no project id so we're using matrix project id with a model method

  self.table_name = 'morphology_matrix_timelines'

  before_update :set_update_date

  def sorted_versions
    #self.matrix.timelines.sort{|a,b| a.updated_at <=> b.updated_at} #added order to matrix.rb
    self.matrix.timelines
  end

  def version_number
    sorted_versions.index(self) + 1
  end

  def number_of_versions
    self.matrix.timelines.length
  end

  def next_version
    self.version_number < self.matrix.timelines.length ? sorted_versions[self.version_number] : nil
  end

  def previous_version
    self.version_number > 1 ? sorted_versions[self.version_number - 2] : nil
  end

  def first_version
    self.is_first_version? ? self : sorted_versions.first
  end

  def is_last_version?
    self.sorted_versions.last == self
  end

  def last_version
    self.is_last_version? ? self : sorted_versions.last
  end

  def is_first_version?
    self.previous_version.nil?
  end

  def name
    self.matrix.name.to_s
  end

  def empty?
    (self.characters.empty? && self.otus.empty? && self.cells.empty?) ? true : false
  end

  def deleted?
    if self.delete_date == nil
      false
    elsif self.delete_date <= DateTime.now.utc
      true
    else
      false
    end
  end

  def mark_deleted
    self.delete_date = DateTime.now()
    self.save!
  end

  def remove_character(character)
    mchar = Morphology::Matrix::MatricesCharacters.find_by_timeline_and_character(self, character)
    mchar.remove_from_list
    mchar.delete_date = DateTime.now.utc
    mchar.save!
  end

  def project
    self.matrix.project
  end

  def self.get_states_for_tooltip(chrs)
    tooltiphash = Hash.new {|hash, key| hash[key] = [ ]}; # initialize space for each new character id to an empty array to hold tooltips by state_num
    unless chrs.empty?
      chr_states = Morphology::ChrState.find(:all, :conditions => ["character_id in (#{chrs.join(',')})"])
      #chr_states.each { |cs| tooltiphash[cs.character_id][cs.state.to_i] = cs.name }
      chr_states.each { |cs| tooltiphash[cs.character_id].push(cs.name) }
    end
    tooltiphash
  end

  def copy(date = DateTime.now)
    date = date.utc
    self.get_objs_by_date(date)
    new_matrix = Morphology::Matrix.new(
      :name => "[copy]" + self.matrix.name + "[" + date.to_s(:short) + "]",
      :created_at => DateTime.now.utc,
      :copied_from_id => self.matrix.id
    )
    new_timeline = Morphology::Matrix::Timeline.create!(
      :description => "Copied from " +
            (self.matrix.name.nil? ? '[no name]' : self.matrix.name) +
            " on " +
            date.to_s(:long) +
            ". \n" +
            (self.description.nil? ? '' : self.description)
    )
    new_matrix.timelines << new_timeline
    new_matrix.save!
    copy_children(new_timeline)
    new_timeline
  end

  def copy_children(new_timeline)
    @otus.each{ |otu| new_timeline.otus << otu }
    @characters.each{ |char| new_timeline.characters << char.create_clone}
    @cells.each { |cell| new_timeline.cells << cell.copy(new_timeline) }
    new_timeline.save!
  end

  def create_next_version
    self.get_objs_by_date
    new_timeline = Morphology::Matrix::Timeline.new(
      :description => self.description,
      :matrix_id   => self.matrix.id
    )
    Morphology::Matrix::Timeline.transaction do
      copy_children(new_timeline)
    end
    new_timeline
  end

  def get_objs_by_date(date = DateTime.now.utc)
    date = date.utc
    @matrices_characters = Morphology::Matrix::MatricesCharacters.includes(:character).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', self.id, date, date).order('position')
    @matrices_otus    = Morphology::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', self.id, date, date).order('position')
    @cells = Morphology::Matrix::Cell.find_by_timeline_and_date(self, date)
    @characters = @matrices_characters.map{|mchar|mchar.character}
    @otus = @matrices_otus.map{|motu|motu.otu}
  end

  def set_update_date
    self.updated_at = DateTime.now.utc
  end

  def export_to_nexus(file_name)
      filename = "#{RAILS_ROOT}/public/nexus/#{file_name}"
      codings_hash = {}
      #Nexus file has a Taxa block, Characters Block and Matrix Block with in characters block
      #This procedure writes these blocks based on the data in the tables

      File.open(filename,  "w") do |file|
        file.print "#NEXUS\n\n"
        file.print "[NEXUS FILE GENERATED BY TOLKIN]\n\n"

        @file = file

        write_taxa_block

        otus.each { |otu| codings_hash[otu.id] = {} } # create space for filling in codings hash

        #Write Characters Block
        #Loop through characters, and each state for every character and write them to file
        file.print "BEGIN CHARACTERS;\n"
        file.print "DIMENSIONS NCHAR=#{self.characters.size.to_s};\n"
        file.print "FORMAT GAP=- MISSING=? SYMBOLS= \" 0 1 2 3 4 5 6 7 8 9\";\n\n";

        write_char_state_labels

        #Matrix Block
        file.print "MATRIX\n\n"
        max_length = self.otus.sort_by{|otu|otu.name.length}.last.name.length
        total_size = max_length + 3 #3 extra for padding
        #max_tabs = (max_len_otu_name / 4)+ 1
        #Matrix block has Otu Name followed by codings in the same order
          #in which characters were written previously
        #Create the hash with codings.  For ease of processing.

        codings_array = self.cells.to_a
        unless codings_array.nil?
          codings_array.each { |i|
            codings_hash[i.otu_id][i.character_id] = i.codings
          }
        end

        self.otus.each { |otu|
          curr_line = ""
          otu_name = otu.name.humanize.gsub(/\s/, "_")
          otu_name = (otu_name =~ /^[\w\s]+$/)? otu_name : "'#{otu_name}'" # put title in quotes if it contains special characters
          curr_line << otu_name

          #Calculate the number of tabs required after OTU name
          curr_line << " "*(total_size - otu_name.length)
          #If there is no coding print a "-"
          #If only one print it as such
          #If more than one, print them within curly bracess
          self.characters.each { |chr|
            coding = codings_hash[otu.id][chr.id]

            if coding.nil? or coding.blank?
              curr_line << "-"
            else
              if coding.length > 1
                if coding == "----"
                  curr_line << "-"
                else
                  tmp_s = coding.to_s
                  #mp_s = tmp_s.gsub(/ /, ',')
                  tmp_s = "{" + tmp_s.gsub(/ /, '') + "}"
                  curr_line << tmp_s
                end
              else
                curr_line << coding
              end
            end
          }
          file.print "#{curr_line}\n"
        }

        file.print(";\nEND;\n")
      end
    filename
    end

  protected

    def write_taxa_block
      @file.print "BEGIN TAXA;\n"
      @file.print "DIMENSIONS NTAX=#{self.otus.size.to_s};\n\n"
      @file.print "TAXLABELS\n\n"

      otus = self.otus
      position = 0
      otu_names = otus.collect do |otu|
        otu_name = otu.name.humanize.gsub(/\s/, "_")
        otu_name = (otu_name =~ /^[\w\s]+$/)? otu_name : "'#{otu_name}'" # put title in quotes if it contains special characters
        "\t[#{position+=1}]\t#{otu_name}"
      end
      @file.print otu_names.join("\n")
      @file.print("\n;\nEND;\n\n")
    end

    def write_char_state_labels
      @file.print "CHARSTATELABELS\n\n"
      characters = self.characters
      position = 0
      chrs_with_states = characters.collect do |chr|
        chr_name = chr.name.humanize.gsub(/\s/, "_")
        chr_name = (chr_name =~ /^[\w\s]+$/)? chr_name : "'#{chr_name}'" # put title in quotes if it contains special characters
        chr_state_str = "\t#{position+=1}\t#{chr_name}"
        unless chr.chr_states.nil?
          chr_state_str << " / "
          chr_state_names = chr.chr_states.collect do |chr_state|
            chr_state_name = chr_state.name.humanize.gsub(/\s/, "_")
            (chr_state_name =~ /^[\w\s]+$/ || chr_state_name.empty?)? chr_state_name : "'#{chr_state_name}'"
          end
          chr_state_str << chr_state_names.join(" ")
        end
      end
      @file.print chrs_with_states.join(",\n")
      @file.print "\n;\n\n"
    end
end