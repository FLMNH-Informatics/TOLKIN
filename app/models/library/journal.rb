# == Schema Information
# Schema version: 20090423194502
#
# Table name: citations
#
#  id                   :integer         not null, primary key
#  type                 :string(255)
#  title                :string(255)
#  short_title          :string(255)
#  translated_title     :string(255)
#  short_author         :string(255)
#  original_publication :string(255)
#  journal              :string(255)
#  volume               :string(255)
#  number               :string(255)
#  issue                :string(255)
#  pages                :string(255)
#  address_id           :integer
#  institution          :string(255)
#  organization         :string(255)
#  edition              :string(255)
#  key                  :string(255)
#  keywords             :string(255)
#  abstract             :string(255)
#  editor               :string(255)
#  language             :string(255)
#  series_editor        :string(255)
#  series_title         :string(255)
#  abbr_series_title    :string(255)
#  series_volume        :string(255)
#  series_issue         :string(255)
#  reprint_edition      :string(255)
#  call_number          :string(255)
#  accession_number     :string(255)
#  issn_or_isbn         :string(255)
#  isbn_or_issn         :string(255)
#  bhp                  :string(255)
#  url                  :string(255)
#  doi                  :string(255)
#  notes                :string(255)
#  access_date          :string(255)
#  research_notes       :string(255)
#  caption              :string(255)
#  type_of_work         :string(255)
#  translator           :string(255)
#  citation_files_id    :integer
#  recpermissions_id    :string(255)
#  updated_by           :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  project_id           :integer
#  publication_id       :integer
#  city                 :string
#  publisher_id         :integer
#  image_id             :integer
#  number_of_volumes    :integer
#  chapter              :string
#  book_title           :string
#  title_id             :integer
#  year                 :integer
#  month                :integer
#  user_id              :integer
#

class Library::Journal < Library::Citation
  #attr_accessible :author, :title, :journal, :year, :volume, :number, :pages, :notes, :doi, :isbn_or_issn, :keywords, :abstract, :url

  def self.custom_attributes
    [ :author, :title, :journal, :year, :volume, :number, :pages, :notes, :doi, :isbn_or_issn, :keywords, :abstract, :url]
  end
  
end
