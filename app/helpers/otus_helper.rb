module OtusHelper
  def link_to_remove_taxon(taxon_id)
    link_to_remote image_tag("x.png", :border=>0),
      :url => remove_taxon_project_otu_path,
      :with => "'taxon_id=#{taxon_id}'",
      :method => :post,
      :confirm => 'Are you sure?'
  end

  def otus_params
    out = "<input type='hidden' name='otu[name]' value='#{@otu.name}'/>"
    out << "<input type='hidden' name='otu[original_position]' value='#{@otu.original_position}'/>"
    out << "<input type='hidden' name='otu[description]' value='#{@otu.description}'/>"
    out
  end

  def catalog_filters
    out = "<div class='filters'>"
    if filters
      out << filters
    end
    out << "</div>"
    out
  end

  def create_version_path(br_it_br, direction)
    case direction
    when :previous
      position = br_it_br.position - 1
    when :next
      position = br_it_br.position + 1
    end
    obj_id = br_it_br.branch.items.for_position(position).first.try(:item).try(:id)
    if !obj_id.nil?
      return  link_to direction.to_s, project_otu_path(@project, obj_id)
    else
      return ""
    end
  end

  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end

  def otus_catalog
    Otus::Catalog.new({
        context: self,
        parent: content_frame,
        collection: @otus
      }).render_to_string
    #    catalog('viewport_content_frame_otu_catalog', @requested, [
    #        { :attribute => "name", :width => 250 },
    #        { :attribute => "otu_groups", :map => 'name', :width => 200 },
    #        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
    #      ], :count => @count
    #    )
  end
end
