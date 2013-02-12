#module citations parser includes parsers for citations
  #parser for endnote format(xml), as of the writing this parser end note did not have a api/documentation/libarary/spec for endnote export format, so add the necessary fields(unparsed by the parser as different assign_* methods in assign_fields method, find a sample endnote file in the docs folder
  require "nokogiri" 

class CitationsParser::EndNoteParser
  attr_reader :records

  def initialize
      @records = Array.new    	
      @doc = ""
  end

  #handles "<record ...</record>" node in the endnote output format
  def handle_record(xml_record, parameters)
    xml_record.children.each do |field|
      assign_field(field, parameters)
    end
    @records << parameters
  end

  def assign_authors(field, parameters)
    field.children.each do |authors|
      authors.children.each do |author|
        temp_person = Library::Author.find(:first, :conditions => CitationsParser::Author.extract_firstlast_names(author.content))
        if(!temp_person.nil?)
          parameters[:contributors] << temp_person
        else
          #parameters[:contributors] << Person.new(CitationsParser::Author.extract_firstlast_names(author.content))
          parameters[:contributors] << Library::Author.new(CitationsParser::Author.extract_firstlast_names(author.content))
        end
      end
    end
  end

  def assign_titles(field, parameters)
    field.children.each do |title|
      if title.name.upcase == "TITLE"
        parameters[:title] = title.content
      end
    end
  end

  def assign_dates(field, parameters)
    field.children.each do |date|
      if date.name.upcase == "YEAR"
        parameters[:year] = date.content
      end
    end
  end


  def assign_keywords(field, parameters)
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


  def assign_urls(field, parameters)
    field.children.each do |related_urls|
      related_urls.each do |url|
        if url.name.upcase == "URL"
          parameters[:url] = url.content
          return
        end
      end
    end
  end

  #add any future feature additions here!
  def assign_field(field, parameters)
    case field.name.upcase
      when "REF-TYPE"
      if REF_TYPE_MAP.has_key?(field.attributes["name"].inner_html.upcase)
        parameters[:type] = REF_TYPE_MAP[field.attributes["name"].inner_html.upcase]
      else
        parameters[:type] = REF_TYPE_MAP["DEFAULT".upcase]
      end
      when "CONTRIBUTORS"
         assign_authors(field, parameters)
      when "TITLES"
         assign_titles(field, parameters)
      when "DATES"
         assign_dates(field, parameters)
      #when "PUBLISHER"
      #parameters[:publisher] = field.content
      when "KEYWORDS"
         assign_keywords(field, parameters)
      when "URLS"
         assign_urls(field, parameters)
      when ATTR_MAP[field.name.intern].to_s.upcase#@@attr_map.has_key?(field.name.intern)
         parameters[ATTR_MAP[field.name.intern]] = field.content
    else
      #parameters[field.name] = field.content
    end

  end

  def self.parse(data)
    doc = Nokogiri::HTML(data)
    nodes = doc.search('records')
    cit_parser = self.new
    nodes.each do |node|
      node.children.each do |xml_record|
        parameters = Hash.new
        parameters[:contributors] = Array.new
        cit_parser.handle_record(xml_record, parameters)
      end
    end
    cit_parser.records
  end

  #mapping from end note to tolkin mapping for the nodes in output xml format.
  ATTR_MAP = {
    :year => :year,
    :title => :title,
    :volume => :volume,
    :number_of_volumes => :number_of_volumes,
    :number => :number,
    :pages => :pages,
#    :section => :section,
    :edition => :edition,
    :date => :year,
    :isbn => :isbn_or_issn,
    :issn => :isbn_or_issn,
    :keyword => :keyword,
    :abstract => :abstract,
    :notes => :notes
  }

  #mapping from endnote to tolkin for the type of citation
  REF_TYPE_MAP = {
    "JOURNAL ARTICLE" => "Citations::Journal",
    "BOOK" => "Citations::Book",
    "OTHERS" => "Citations::Others",
    "DEFAULT" => "Citations::Others",
    "BOOK SECTION" => "Citations::BookSection"
  }
end