class Molecular::Resources::Ncbi::EUtils::ESummary

  def self.from_xml xml_string
    #no longer using hipricot
    #esummaries = [ ]
    #document = Hpricot(xml_string)
    #return [ ] unless document.at('/eSummaryResult/ERROR').nil?
    #(document/'/eSummaryResult/DocSum').each do |summary|
    #  esummary = {}
    #  (summary/'/item').each do |summary_item|
    #    if summary_item["name"]
    #      esummary[summary_item["name"].underscore] = summary_item.inner_html.sub(/<!\[CDATA\[(.+?)\]\]>/, '\1')
    #    end
    #  end
    #  [ { from: 'caption', to: 'accession' },
    #    { from: 'title',   to: 'description' },
    #    { from: 'gi',      to: 'id' }
    #  ].inject(esummary) do |esummary, conv|
    #    esummary[conv[:to]] = esummary.delete(conv[:from]) if esummary[conv[:from]]
    #    esummary
    #  end
    #  esummaries << { bioentry: esummary }
    #end
    #esummaries
    esummaries = []
    document = Hash.from_xml(xml_string)

    document['eSummaryResult']['DocSum'].each do |summary|
    #  esummary = {}
    #  summary[:item].each do |item|
    #    if item[:name]
    #      esummary[:item][:name]
    #    end
    #  end
    end
  end
end
