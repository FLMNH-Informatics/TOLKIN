module Noteworthy
  def add_note(note, author)
    Note.create!(:item => self, :note => note, :author => author)
  end
end
