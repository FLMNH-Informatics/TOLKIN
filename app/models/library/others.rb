class Library::Others < Library::Citation
  #attr_accessor :author, :title, :journal, :year, :volume, :number, :pages, :month, :note, :key
  #is the key unique?
  #attr_accessible :author, :title, :journal, :year, :volume, :number, :pages, :notes, :key, :edition, :publication, :isbn, :keywords, :abstract, :url

  def self.custom_attributes
    [ :author, :title, :journal, :year, :volume, :number, :pages, :notes, :key, :edition, :publication, :isbn, :keywords, :abstract, :url]
  end
end
