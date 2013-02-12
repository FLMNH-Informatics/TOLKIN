class Molecular::Resources::Ncbi::EUtils::ESearch
  require 'nokogiri'
  
  def self.from_xml xml_string
    ids = []
    results = Hash.from_xml(xml_string)
    if results['eSearchResult']['IdList']['Id'].nil?
      if results['eSearchResult']['TranslationStack'].nil?
        error_list = results['eSearchResult']['ErrorList']
        gen_message = results['eSearchResult']['WarningList']['OutputMessage'].chomp('.')
        error_message = error_list.keys.inject('') { |msg, key| msg << %(#{key}  "#{error_list[key]}"<br />)}
        return { :errormsg => "<em>" + gen_message + '.<br />Reason(s): ' + error_message + "</em>" }
      else
        new_search_term = {"term" => results['eSearchResult']['TranslationStack']['TermSet'].first['Term'].delete('/"')}
        Molecular::Resources::Ncbi::EUtils.esearch(new_search_term)
      end
    else
      if results['eSearchResult']['WebEnv'].nil?
        [*results['eSearchResult']['IdList']['Id']].each {|id| ids << id}
        { :count => results['eSearchResult']['Count'], :ids => ids, :method => 'ids'}
      else
        { :count => results['eSearchResult']['Count'], :webenv => results['eSearchResult']['WebEnv'], :querykey => results['eSearchResult']['QueryKey'], :method => 'history' }
      end
    end
  end
end
