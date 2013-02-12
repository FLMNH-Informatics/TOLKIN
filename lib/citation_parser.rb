module CitationParser
  require 'net/http'
  require 'uri'
#   require 'bibtex/parser'
#   require 'xml'

  class Parser
    #FIXME: i need to use nokogiri to work in 1.9
    def Parser.parse data
      records = Array.new
      doc = LibXML::XML::Document.string(data)
      nodes = doc.find('records')
      nodes.each do |node|
        node.children.each do |xml_record_node|
          records << Hash.from_xml(xml_record_node.to_s)
        end
      end
      debugger
      records
    end
  end

end
