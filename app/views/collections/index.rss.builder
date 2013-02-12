xml.rss(:version => "2.0", "xmlns:georss" => "http://www.georss.org/georss") {
  xml.channel {
    xml.title("#{@current_project} Collections GeoRSS Feed")
    xml.link(request.url)
    xml.description("Collections data with location info")
    xml.language('en-us')
    for collection in @collections
      xml.item do
        xml.title([collection.collector, collection.collection_number].compact.join(' '))
        xml.description(%{
          #{collection.country.blank? ?        "" : "<b>Country:</b> #{collection.country}<br />" }
          #{collection.island.blank? ?         "" : "<b>Island:</b> #{collection.island}<br />" }
          #{collection.state_province.blank? ? "" : "<b>State/Province:</b> #{collection.state_province}<br />" }
          #{collection.locality.blank? ?       "" : "<b>Locality:</b> #{collection.locality}<br />" }
        })
        xml.colDate(collection.start_date.try(:strftime, "%a, %d %b %Y"))
        xml.link(project_collection_path(@current_project.id,collection.id))
        xml.georss :point do
          xml.text! "#{collection.calc_lat_dd} #{collection.calc_long_dd}" # FIXME: show dd or deg min sec based on what user has provided
        end
      end
    end
  }
}
