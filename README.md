# tolkin_2

(<a href="www.tolkin.org">www.tolkin.org</a> | <a href="http://demo.tolkin.org">demo.tolkin.org</a>)

## The Tree of Life Knowledge Information Network
NOTE: create globals.rb in config/initializers following globals.rb.EXAMPLE

## Notes
### CSV Export workaround until proxy issue is fixed for large files
Note: must be in `rails console`
```bash
$ rails console
```
```ruby
#must be in rails console
#because of the passkey system, you need the rtid of the project you want to export

#get projects with rtid
Project.all.map{|p| [p.project_id, p.name, p.rtid] }
project = Project.find(PROJECT_ID)

#get the taxa
all_taxa = Taxon.where(owner_graph_rtid: project.rtid)

#params for all columns
params = ["name","author","year","status","commonname","accepted_name","type_species","type_collection","type_locality","general_distribution","notes","publication","volume_num","pages","infra_name","infra_author","custom_tag","type_herbaria","neotype","sub_genus","section","major_group","subclade","publication_date","ingroup_clade","old_accepted_name","temp_family","temp_genus","temp_species","chromosome_number","phylogenic_relationship","uses","toxicity","description","conservation_status","editors","basionym","comments","habitat","subsection","type_date","infra_name_2","infra_author_2","Tolkin URL","GUID","GUID URL"]

#save csv in memory
csv = CsvExporter.Export.export_to_csv(all_taxa, params)

#write file
File.open("#{project.name}_all_taxa.csv", "w") { |file| file.write(csv) }
```
