#TODO make sure this still works with FileUtils; FileUtils preferred over ftools
require "fileutils"
class Library::Citation < ActiveRecord::Base
  include GenericSearch
  belongs_to :citation_file, :class_name => "Library::CitationFile", :foreign_key => "citation_file_id"

  #accepts_nested_attributes_for :citations_attribute

#  def citations_attribute_attributes=(attrs)
#    citations_attribute.update_attributes!(attrs)
#  end

  has_many :contributorships, :class_name => "Library::Contributorship", order: "position"
  has_many :contributors, :through => :contributorships, source: :author, order: "contributorships.position"
  has_many :authors, :through => :contributorships, order: "contributorships.position"

  belongs_to :creator, class_name: 'User', foreign_key: :user_id

  belongs_to :project
  belongs_to :publisher,      :class_name => "Library::Publisher"
  belongs_to :publication,    :class_name => "Library::Publication"
  has_many :citations_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :citations_images
  has_and_belongs_to_many :taxa
  has_and_belongs_to_many :characters,              :class_name => 'Morphology::Character'
  has_and_belongs_to_many :otus,                    :class_name => 'Morphology::Character'  ##This can't be right, :otus with class of morph::Character??????
  has_and_belongs_to_many :chr_states,              :class_name => 'Morphology::ChrState'
  has_and_belongs_to_many :state_codings,           :class_name => 'Morphology::StateCoding'
  has_and_belongs_to_many :morphology_matrix_cells,
                          :class_name => 'Morphology::Matrix::Cell',
                          :join_table => 'morphology_matrix_cell_citations',
                          :foreign_key => 'citation_id'

  # run write_file after save to db
  #before_save :write_file

#  belongs_to :book_title,    class_name: 'Library::Publication', foreign_key: :publication_id,    primary_key: :l_publication_id
#  belongs_to :series_title,  class_name: 'Library::Publication', foreign_key: :publication_id,  primary_key: :l_publication_id
#  belongs_to :journal_title, class_name: 'Library::Publication', foreign_key: :publication_id, primary_key: :l_publication_id
  #alternate single reference to title
  belongs_to :publication_title, class_name: 'Library::Publication', foreign_key: :publication_id, primary_key: :l_publication_id

  scope :for_project,        lambda { |project| { :conditions => [ "project_id = ?", project.project_id] } }

  def self.custom_attributes
    @@custom_attributes ||= column_names
  end

  def book_title
    publication && publication.publication_type == 'book' ?
      publication : nil
  end

  def series_title
    publication.nil? ? nil :
      publication.publication_type == 'book' ?
        publication.parent :
      publication.publication_type == 'series' ?
        publication :
        nil
  end
  
  def author
    #default value returned to appeeze auto text field
    nil
  end

  def journal_title
    publication && publication.publication_type == 'journal' ?
      publication : nil
  end

  select_scope :display_name, {
    select: [
      :year,
      :title,
      :volume,
      :issue,
      :pages,
      :editor,
      :number
    ]
  }
  def display_name
    @disp_name ||= build_display_name
  end

  composite :authors_joined, [

  ]
  def authors_joined
    authors.join(', ')
  end

  #used by old custom ciations search, remove this when discontinuing the feature
  def self.search_columns
    [ "title" , "year", "author"]
  end

  #updates the citation with other dependencies used primarily from update citations(citation controller)
#  def update_with_dependencies(options = {}, current_user, current_project)
#    Library::Citation.transaction do
#      options[:citation].delete(:type)
#
#      handle_titles options[:citation], current_user, current_project
#
#      citation_attrs = options[:citation].dup
#      citation_attrs.delete(:contributors)
#      update_attributes!(citation_attrs)
#      handle_attachments cit_params[:attachment] #TODO: this doesnt work with the transaction so the file is stored even if the transaction fails, needs to do better
#      handle_contributors cit_params[:contributors], current_project
#    end
#  end

  #creates multiple citations at a time for bulk upload, via citation parsers
  def self.bulk_create(options = {})
    records = CitationsParser::EndNoteParser.parse(options[:attachment][:bibfile].read)
    new_citations = Array.new
    citation_types = Library::CitationType.find(:all).collect {|record| record.name }
    records.each do |record|
      Library::Citation.transaction do
        debugger
        cit = Library::Citation.new record
        #changing people to contributors in the next line. if error revert back
#        cit.people = record[:people] if record[:people]
        cit.contributors = record[:people] if record[:people]
        cit.type = citation_types.include?(record[:type]) ? record[:type] : "Library::Others"
#        cit.people.each do |person|
        cit.contributors.each do |person|
          person.project_id = options[:project_id]
        end
        cit.project_id = options[:project_id]
        if cit.save!
          new_citations << cit.id
        else
          record[:errors] = cit.errors.full_messages
        end
      end
    end
    [new_citations, records]
  end

  def save
    super
    self.book_title_pid = self.project.book_titles.find(self.book_title.vid).pid if self.book_title

    #(!self.book_title || !self.book_title.new_record? || (self.book.save && ) ) && super
  end

  def handle_attachments attachment
    if(attachment)
      read_file attachment
      self.citation_file = write_file
      save!
    end
  end


  #TODO: ASK GREG WHERE AUTHOR IS CREATED
  def handle_contributors contrib_params, project
 
    ((contrib_params && contrib_params[:ids])||[]).each do |id|
      if(id[0] == '!')
        (contributorship = self.contributorships.first(conditions: { author_id: id[1..-1] })) \
        && contributorship.destroy
        #also delete the author if it isn't linked to any citation
        if Library::Contributorship.first(:conditions => {:author_id => id[1..-1]}) == nil
          Library::Author.delete(id[1..-1])
        end
      else
     
        position = contrib_params[:positions].inject({}){|memo, (k,v)| 
          memo[k.to_s.dup.force_encoding('utf-8')] = v
          memo 
        }[id.to_s] || fail('could not find position') # FIXME: encoding error needs to be fixed with rails or webrick patch, hash keys are being wrongly asciified 
        contributorship = self.contributorships.first(conditions: { author_id: id })
        if contributorship
          contributorship.position = position
          contributorship.save!
        else
          contributor = project.authors.find(id)
          self.contributorships.create!(
            author_id: contributor.id,
            position: position
          )
        end
      end
    end
  end

# 12/22/2010 - ChrisG replacing this new method with old method - I remember running into problems getting the cascade
# save to work with this new method
#  def self.new params = {}
#    cit = super(params)
#    cit.type = "Library::#{params[:type]}"
#    cit.book_title ||= cit.project.book_titles.find_by_pid(params[:book_title_pid]) unless params[:book_title_pid].blank?
#    cit.book_title ||=
#      cit.project.book_titles.find_by_value(params[:book_title_value]) \
#      ||
#      cit.project.book_titles.new(
#        value: params[:book_title_value],
#        publication_type: 'book'
#      ) \
#    unless params[:book_title_value].blank?
#    cit
#    #factory 'Hello', params
#  end

  # needs refactoring - has been corrupted within
  def params_for_mass_assign init_params
    cit_params = init_params.dup
    cit_params.delete(:contributors)
    # ugly cludge below but this should work
    # sets publication as journal or series if just one of those provided
    # if book and series or just book, book is set as publication, with series set as book's parent
    if(!cit_params[:journal_title_id].blank?)
      cit_params[:publication_id] = cit_params[:journal_title_id]
    elsif(!cit_params[:book_title_id].blank?)
      cit_params[:publication_id] = cit_params[:book_title_id]
      if(!cit_params[:series_title_id].blank?)
        Library::Publication.find(cit_params[:book_title_id]).update_attributes!({
          parent_id: cit_params[:series_title_id]
        })
      end
    elsif(!cit_params[:series_title_id].blank?)
      cit_params[:publication_id] = cit_params[:series_title_id]
    end
    cit_params.delete(:journal_title_value)
    cit_params.delete(:series_title_value)
    cit_params.delete(:book_title_value)
    cit_params.delete(:journal_title_id)
    cit_params.delete(:series_title_id)
    cit_params.delete(:book_title_id)
    cit_params.delete(:attachment)
    cit_params.delete(:publisher_name)
    #cit_params.delete(:type)  - dont understand why this was be deleted
    cit_params
  end

  def update_with params, user, project
#    begin
      self.transaction do
        params[:publisher_id] = handle_publisher params, project #.delete(:publisher_name) if params.has_key?(:publisher_name)
        handle_titles       params, user, project
        update_attributes!(params_for_mass_assign(params))
        #DEMO DISABLED
        handle_attachments params.delete(:attachment) #TODO: this doesnt work with the transaction so the file is stored even if the transaction fails, needs to do better
        handle_contributors params.delete(:contributors), project
      end
      true
#    rescue => e
#      debugger
#      false
#    end
  end

  def handle_publisher cit, project
    pub = nil
    
    if !cit[:publisher_name].blank?
      pub = project.publishers.find(:first, :conditions => {:name => cit[:publisher_name].strip})
      if pub == nil
        pub = project.publishers.create!(:name => cit[:publisher_name])
      end
      pub = pub.id
    end
    pub
  end

  def handle_title (citation, publication_type, current_user, current_project)
    title_value = citation.delete("#{publication_type}_title_value".to_sym)
    unless title_value.blank?
      title =
        current_project.
          publications.
          find_by_publication_type_and_value(
            publication_type.to_s,
            title_value.strip
          )
      title ||=
        current_project.
          publications.
          create!(
            value: title_value,
            publication_type: publication_type.to_s,
            created_at: Time.now,
            creator_id: current_user.id
          )
      citation["#{publication_type}_title_id".to_sym] = title.id
    end
  end

  def handle_titles citation_params, current_user, current_project
    handle_title citation_params, :journal, current_user, current_project
    handle_title citation_params, :book, current_user, current_project
    handle_title citation_params, :series, current_user, current_project
  end

  class << self
    def create_with params, user, project
      citation = params[:type].constantize.new
      begin
        citation.transaction do
          citation.creator = user
          citation.project = project
          citation.save!
          citation.update_with(params, user, project)
        end
        true
      rescue => e
        debugger
        false
      end
    end

    def create! *args
      fail 'do not use me, use create'
    end


#    def create_citation params, user, project
#      Library::Citation.transaction do
#        @citation =
#        @citation.create_with_dependencies(params, user, project)
#      end
#      @citation
#    end




  end

  private


  def read_file(data)
    @file_data = data
  end

   #FIXME writing file is a security risk
  def write_file
    if @file_data
      pubfile = Library::CitationFile.new
      pubfile.name = @file_data.original_filename.split('/').last # why append id when being stored in id folder "#{id}_#{@file_data.original_filename.split('/').last}"
      pubfile.original_name = @file_data.original_filename.split('/').last

      if !File.exists?("#{LIBRARY_PUBLICATION_ATTACHMENT_STORAGE_PATH}/#{id}")
        FileUtils.mkdir("#{LIBRARY_PUBLICATION_ATTACHMENT_STORAGE_PATH}/#{id}")
      end
      File.open("#{LIBRARY_PUBLICATION_ATTACHMENT_STORAGE_PATH}/#{id}/#{pubfile.name}", "wb") do |file|
        file.write(@file_data.read)
        file.close
      end

      pubfile.save!
      pubfile
      #this could be made more secure by using someother naming scheme
      # put calls to other logic here - resizing, conversion etc.
    end
  end

  def build_display_name
    case type
    when 'Library::Book'
      disp_name = ""
      before_last = contributors[0..-2].collect(&:name).join(", ")
      disp_name << [(before_last.blank? ? nil : before_last), contributors[-1].try(:name) ].compact.join(", and ")
      disp_name << "." unless disp_name[-1] == '.'
      disp_name << " (#{year})" unless year.blank?
      #disp_name << (year.to_s + " ")if year
      disp_name << ". #{title}" unless title.blank?
      disp_name << ". #{publication.value}" unless publication.nil? || publication.value.blank? || publication.value == title
      disp_name << ". #{publisher.name}" if publisher && publisher.name
      disp_name << ", #{city}" unless city.blank?
#      disp_name << ". <i>#{journal}</i>" unless journal.blank?
#      disp_name << (issue.blank? ? volume.blank? ? "" : " [#{volume}]" : " [#{volume}](#{issue})")
      disp_name << ", #{pages}" unless pages.blank?
      disp_name << "." unless !disp_name || disp_name[-1] == '.'
    when 'Library::BookSection'
      disp_name = ""
      before_last = contributors[0..-2].collect(&:name).join(", ")
      disp_name << [(before_last.blank? ? nil : before_last), contributors[-1].try(:name) ].compact.join(", and ")
      disp_name << "." unless !disp_name || disp_name[-1] == '.'
      disp_name << " (#{year})" unless year.blank?
      #disp_name << (year.to_s + " ")if year
      disp_name << ". \"#{title}.\"" unless title.blank?
      disp_name << " In: #{publication.value}" unless publication.nil? || publication.value.blank?
      disp_name << " #{volume}" unless volume.blank?
      disp_name << ": #{pages}" unless pages.blank?
      disp_name << ", #{editor}" unless editor.blank?
      disp_name << ". #{publisher.name}" if publisher && publisher.name
      disp_name << ", #{city}" unless city.blank?
#      disp_name << ". <i>#{journal}</i>" unless journal.blank?
#      disp_name << (issue.blank? ? volume.blank? ? "" : " [#{volume}]" : " [#{volume}](#{issue})")

      disp_name << "." unless disp_name[-1] == '.'
    else
      disp_name = ""
      before_last = contributors[0..-2].collect(&:name).join(", ")
      disp_name << [(before_last.blank? ? nil : before_last), contributors[-1].try(:name) ].compact.join(", and ")
      disp_name << "." unless !disp_name || disp_name[-1] == '.'
      disp_name << " (#{year})" unless year.blank?
      #disp_name << (year.to_s + " ")if year
      disp_name << ". #{title}" unless title.blank?
      disp_name << ". <i>#{journal_title}</i>" unless journal_title.blank?
      disp_name << (number.blank? ? volume.blank? ? "" : " #{volume}" : " #{volume}(#{number})")
      #disp_name << (number.blank? ? "" : "#{number}")
      disp_name << ", #{pages}" unless pages.blank?
      disp_name << "." unless disp_name[-1] == '.'
    end
   return disp_name
  end

  def self.all_column_names
    column_names#.concat(Library::CitationsAttribute.column_names)
  end

#  [:journal ,:volume , :number , :issue , :pages , :edition , :key , :keywords , :abstract , :editor , :series_editor , :series_title , :series_volume , :isbn_or_issn , :url , :doi , :notes , :city , :number_of_volumes, :chapter , :book_title ].each do |attr|
#    define_method(attr) { citations_attribute ? citations_attribute.send(attr)  : nil }
#  end


  def self.year_conditions
    ["citations.year ILIKE ?",  "%#{@@search_param[:year]}%" ] unless @@search_param[:year].blank?
  end

  def self.conditions
    [conditions_clauses.join(@@search_param[:binop].upcase.eql?('AND') ? ' AND ' : ' OR ' ), *conditions_options]
  end

  def self.conditions_clauses
    conditions_parts.map { |condition| condition.first }
  end

  def self.conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end

  def self.conditions_parts
    [:year,:title, :author].map { |m| send(m.to_s+"_conditions") }.compact
  end

  def self.author_conditions
    ["(authors.name ILIKE ?)" ,  "%#{@@search_param[:author].strip}%"] unless @@search_param[:author].blank?
  end

#  def self.keyword_conditions
#    ["citations_attributes.keywords ILIKE ? ", "%#{@@search_param[:keywords].strip}%" ] unless @@search_param[:keywords].blank?
#  end

  def self.title_conditions
    ["citations.title ILIKE ?", "%#{@@search_param[:title].strip}%" ] unless @@search_param[:title].blank?
  end

  #TODO need to get rid of this or the one method in application.rb, need to find a better way to search multiple column as a compound column
  def self.citation_advanced_search(project, options = {})
    @@search_param = options[self.to_s.to_sym]
    find_options = ({ :page => options[:page] || 1,  :per_page => 20, :order => "title" })
    if !@@search_param[:author].blank?
      find_options.merge!(
        :joins => %{
          INNER JOIN contributorships ON contributorships.citation_id=citations.id
          INNER JOIN authors ON contributorships.author_id=authors.id
        }
      )
    end
    find_options.merge!( :conditions => self.conditions ) unless self.conditions[1..-1].empty?
    project.citations.paginate(find_options )
  end

#  def authors
#    raise "Not Implemented yet fix the catalog generator to accomodate calling helper methods"
##       citation.people.each do |author|
##        link_to author.display_name, edit_project_person_path(params[:project_id],author.id )
##        end
#  end

  #methods for search filter
  def self.searchable_columns
      @searchable_columns  ||= get_searchable_columns
  end

  def self.get_searchable_columns
    search_columns =  [ "title", "year" ].inject([]) {| filters ,col_name|  filters << {"name" => columns_hash[col_name].name, "type" => columns_hash[col_name].type.to_s } }
    #search_columns << { "name" => "otu_groups_id", "type" => "integer"}
    search_columns << { 'label' => 'Authors', 'name' => "authors_fulltext", 'type' => "string" }
    search_columns << {"name" => "publication", "type" => "string"}
    search_columns << {"name" => "publisher", "type" => "string"}
    ##, "value" => "authors_joined"}
  end
end
