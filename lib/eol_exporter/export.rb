# only designed for Taxa module - GHT 4-24-12

class EolExporter::Export

  def initialize

  end

  def self.to_eol recs, column_names

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
       xml.root {
        recs.each do |t|
          url = PublicLicense.where(:id => t.project.public_license_id).first.url
          xml.taxon(:name => t.name){
            #first add EOL required entities/column/attributes (same thing)
            #identifier is unique to project...but not unique to tolkin if project is ever moved out of Tol.

            xml.send(:'dc:identifier', ':: ' + t.name)

            xml.audience 'General public'

            xml.send(:'dc:source', 'Tolkin project') #FIXME - should be full path to public species page
            xml.subject 'General Description'

            #use send() for names with special characters
            #and no declared namespace with :

            xml.synonym( :relationship => t.name){
              xml.text t.name
            }
            xml.send(:'dwc:ScientificName', t.name)
            #now add user selected attributes
            #remove unnecessary columns
            column_names - [:name,:id]

            column_names.each do |c|
              xml.dataObject{
                xml.agent(:role => 'compiler'){
                  xml.text 'Tolkin'
                }
                xml.agent(:role => 'author')

                xml.license url #t.project.public_license.url
                xml.dataType 'text'
                #disambiguate with _ from ruby methods
                xml.subject_  c
                xml.description(:'xml:lang' => 'en'){
                  xml.text t.send(:"#{c}")
                }
              }
            end

          }
        end
      }
    end

    return builder.to_xml
  end

end