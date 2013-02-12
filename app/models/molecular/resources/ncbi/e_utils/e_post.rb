# To change this template, choose Tools | Templates
# and open the template in the editor.

class Molecular::Resources::Ncbi::EUtils::EPost
  def self.from_xml xml_string
    #Create an Object for storing the XML element data
    document = Hpricot(xml_string)
    fail "problem communicating with NCBI" unless document.at('/ePostResult/ERROR').nil?
    querykey = document.at('/ePostResult/QueryKey').inner_html
    webenv = document.at('/ePostResult/WebEnv').inner_html
    { :querykey => querykey, :webenv => webenv }
  end
end
