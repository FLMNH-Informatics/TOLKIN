require 'library/citations/catalog'
module CitationsHelper
  require 'net/http'
  require 'uri'
#   require 'bibtex/parser'
#   require 'xml'
  
  def author_name_field
    @author_name_field ||= Library::Citations::AuthorNameAutoTextField.new(
      context: self,
      model_object: @citation,
      parent: viewport_window
    )
  end

  def publisher_name_field
    @publisher_name_field ||= Library::Citations::PublisherNameAutoTextField.new(
      context: self,
      model_object: @citation,
      parent: viewport_window
    )
  end

  def journal_title_field
    @journal_title_field ||= Library::Citations::JournalTitleAutoTextField.new(
      context: self,
      model_object: @citation,
      parent: viewport_window
    )
  end

  def book_title_field
    @book_title_field ||= Library::Citations::BookTitleAutoTextField.new(
      context: self,
      model_object: @citation,
      parent: viewport_window
    )
  end

  def series_title_field
    @series_title_field ||= Library::Citations::SeriesTitleAutoTextField.new(
      context: self,
      model_object: @citation,
      parent: viewport_window
    )
  end

  def context
    @context ||= Context.new({
      interact_mode: interact_mode,
      project: @current_project,
      controller_name: controller_name,
      host: request.host_with_port
    })
  end
  
  def citation_delete
    if interact_mode == "edit"
      %(<img class="delete_citation" src="/images/delete.gif" alt="delete citation" width="12px" height="12px" />      )
    else
      ''
    end
  end

  def delete_citation_path
    link_to_remote( image_tag("delete.gif", :size => "12x12" ),
    :url=>     delete_citation_project_taxon_path(params[:project_id], params[:id]),
    :method => :delete,
    :confirm => 'Are you sure you want to delete?'
  )
  end
  
  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def authors_catalog
    @authors_catalog ||= Library::Citations::AuthorsCatalog.new(
      parent: viewport_window,
      context: self,
      authors: @citation.authors
    )
  end

  def citations_catalog
    Library::Citations::Catalog.new({
      collection: @citations,
      context: self,
      parent: content_frame
    }).render_to_string
#    catalog('viewport_content_frame_citation_catalog', @requested, [
#
#        { :attribute => "year", :width => 200 },
#        { :attribute => "title", :width => 250 },
#        { :attribute => "publication",  :width => 150 },
#        { :attribute => "type",  :width => 150 }
#      ], :count => @count
    #)
  end
  
  def read_bulk_create_file(data)
    @books = Array.new
    BibTeX::Parser.parse_string(data).map do |entry|
      i = 0
      debugger
      book = Hash.new
      entry.fields.each do |field|
        book[field[0]]=field[1].value
      end
      puts book.inspect
      puts "end of book\n"
      #entry.reject_fields BadFields
      @books[i] =  book
      i=+1
      debugger
    end
  end

  def full_author_name author
    full_name = ""
    if !author.prefix.nil?
      full_name.concat(author.prefix)
    end
    full_name.concat(author.first_name.try(:humanize) || '')
    if !author.middle_name.nil?
      full_name.concat(author.middle_name.try(:humanize) || '')
    end
    if !author.last_name.nil?
      full_name.concat(author.last_name.try(:humanize) || '')
    end
    if !author.suffix.nil?
      full_name.concat(author.suffix.try(:humanize) || '')
    end
    full_name.underscore.try(:humanize).titleize
  end

  #pseudo_name for journal is "journal article" so using this, could extend this in future as per the changes to names displayed
  def get_pseudo_citation_type_name name
    case name.upcase
      when "JOURNAL"
      return "Citation"
    else
      return name
    end
  end

  def get_pseudo_column_name name
    temp = name
    case temp.upcase
      when "DOI"
      return name.upcase
      when "URL"
      return name.upcase
      when "ISBN_OR_ISSN"
      return "ISBN/ISSN"
    else
      return name.try(:humanize)
    end
  end

  #endnote parser
  class Record
    #attr_accessor :type, :title, :year, :journal, :volume, :number, :pages, :keywords, :abstract, :issn, :url, :doi, :notes, :edition, :editor, :city
    def initialize
      @authors = Authors.new
    end
  end

  class Records
    def initialize
      @record_list = Array.new;
    end

    def add(record)
      if record.class == Record.class
        @record_list <<  record
      else
        throw Exception.new("Not a type of "+ this.class.to_s)
      end
    end
  end

  class Authors
    def initialize
      @author_list = Array.new;
    end
    def add(author)
      if author.class == Author.class
        @author_list <<  author
      else
        throw Exception.new("Not a type of "+ this.class.to_s)
      end
    end
  end

  class Author
    #need to improve this function being used also from people_controller
    def Author.extract_firstlast_names(name, splitter=',')
      temp = name.split(splitter)
      if temp.size>0
        case temp.size
          when 1
          return {:last_name => temp[0].strip.downcase}
          when 2
          return {:last_name => temp[0].strip.downcase, :first_name => temp[1].strip.downcase}
          when 3
          return {:last_name => temp[0].strip.downcase, :first_name => temp[1].strip.downcase, :middle_name => temp[2].strip.downcase}
        else
          return {:last_name => temp[0].strip.downcase}
        end
      end
    end

    def initialize(first_name, last_name)
      @first_name = first_name
      @last_name = last_name
    end
    def first_name
      @first_name
    end
    def last_name
      last_name
    end
  end

  class Publisher
    attr_accessor :name, :url
  end
  class Keyword
    def initialize keyword
      @keyword = keyword
    end
  end
  class Keywords
    def initialize
      @keywords = Array.new;
    end

    def add(keyword)
      if keyword.class == Keyword.class
        @keywords <<  record
      else
        throw Exception.new("Not a type of "+ this.class.to_s)
      end
    end
  end



  class Temp
    def Temp.handle_record(record, parameters)
      #puts record.name
      rec = Record.new
      record.children.each do |field|
        Temp.assign_field(rec, field, parameters)
      end
      return rec
    end

    def Temp.assign_authors(field, parameters)
      field.children.each do |authors|
        authors.children.each do |author|
          #author.children.each do |author_style|
          #puts author.content
          temp_person = Person.find(:first, :conditions => Author.extract_firstlast_names(author.content))
          if(!temp_person.nil?)
            parameters[:people] << temp_person
          else
            parameters[:people] << Person.new(Author.extract_firstlast_names(author.content))
          end
          #puts author.content
          #end
        end
      end
    end

    def Temp.assign_titles(field, parameters)
      field.children.each do |title|
        if title.name.upcase == "TITLE"
          parameters[:title] = title.content
        end
      end
    end

    def Temp.assign_dates(field, parameters)
      field.children.each do |date|
        if date.name.upcase == "YEAR"
          parameters[:year] = date.content
        end
      end
    end


    def Temp.assign_keywords(field, parameters)
      temp = ""
      field.children.each do |keyword|
        if keyword.name.upcase == "KEYWORD"
          if temp!= ""
            temp = temp + ", " +keyword.content.strip
          else
            temp = keyword.content.strip
          end
        end
      end
      if(temp.size >0)
        parameters[:keywords] = temp.chop
      end
    end


    def Temp.assign_urls(field, parameters)
      field.children.each do |related_urls|
        related_urls.each do |url|
          if url.name.upcase == "URL"
            parameters[:url] = url.content
            return
          end
        end
      end
    end

    def Temp.assign_field(rec, field, parameters)
      #puts field.name #name of field eg: <title.. > </title>
      #debugger
      case field.name.upcase
        when "REF-TYPE"
        if @@ref_type_map.has_key?(field.attributes["name"].upcase)
          parameters[:type] = @@ref_type_map[field.attributes["name"].upcase]
        else
          parameters[:type] = @@ref_type_map["DEFAULT".upcase]
        end
        when "CONTRIBUTORS"
        Temp.assign_authors(field, parameters)
        when "TITLES"
        Temp.assign_titles(field, parameters)
        when "DATES"
        Temp.assign_dates(field, parameters)
        #when "PUBLISHER"
        #parameters[:publisher] = field.content
        when "KEYWORDS"
        Temp.assign_keywords(field, parameters)
        when "URLS"
        Temp.assign_urls(field, parameters)
        when @@attr_map[field.name.intern].to_s.upcase#@@attr_map.has_key?(field.name.intern)
        parameters[@@attr_map[field.name.intern]] = field.content
      else
        #parameters[field.name] = field.content
      end

    end

    def Temp.parse data
      #parser = LibXML::XML::Parser.file('Bibliographyxml.xml')
      #doc = parser.parse
      doc = LibXML::XML::Document.string(data)
      nodes = doc.find('records')
      records = Array.new
      nodes.each do |node|
        node.children.each do |record|
          parameters = Hash.new
          parameters[:people] = Array.new
          Temp.handle_record(record, parameters)
          puts parameters.inspect
          records << parameters
        end
      end
      debugger
      records
    end

    @@attr_map = {
      :year => :year,
      :title => :title,
      :volume => :volume,
      :number_of_volumes => :number_of_volumes,
      :number => :number,
      :pages => :pages,
      :section => :section,
      :edition => :edition,
      :date => :year,
      :isbn => :isbn_or_issn,
      :issn => :isbn_or_issn,
      :keyword => :keyword,
      :abstract => :abstract,
      :notes => :notes
    }
    @@ref_type_map = {
      "JOURNAL ARTICLE" => "Journal",
      "BOOK" => "Book",
      "OTHERS" => "Others",
      "DEFAULT" => "Others",
      "BOOK SECTION" => "BookSection"
    }
  end


  @attr_map = {
    :ref_type => :klass,
    #:author => :author,
    :author_primary => :citation_name_strings,
    :author_secondary => :citation_name_strings, #RefWorks loads Editors here
    :title => :title,
    :short_title => :short_title,
    :translated_title => :translated_title,
    :title_primary => :title_primary,
    :title_secondary => :title_secondary,
    :year => :year,
    :month => :month,
    :title_tertiary => :publication, # RefWorks loads Conference Proceeding publication data here
    :keyword => :keywords,
    :pub_year => :publication_date,
    :periodical => :publication,
    :original_periodical => :original_publication,
    :periodical_full => :publication,
    :periodical_abbrev => :publication,
    :journal => :journal,
    :volume => :volume,
    :number => :number,
    :issue => :issue,
    :pages => :pages,
    :start_page => :start_page,
    :other_pages => :end_page, #RefWorks loads end page here
    :organization => :organization,
    :institution => :institution,
    :keywords => :keywords,
    :abstract => :abstract,
    :publisher => :publisher,
    :editor => :editor,
    :language => :language,
    :series_editor => :series_editor,
    :series_title => :series_title,
    :abbr_series_title => :abbr_series_title,
    :series_volume => :series_volume,
    :series_issue => :series_issue,
    :reprint_edition => :reprint_edition,
    :call_number => :call_number,
    :accession_number => :accession_number,
    :issn => :issn,
    :isbn => :isbn,
    :bhp => :bhp,
    :doi => :doi,
    :url => :url,
    :notes => :notes,
    :access_dates => :access_dates,
    :research_notes => :research_notes,
    :caption => :caption,
    :translator => :translator,
    #:original_data => :original_data
  }

end
