module Library
  module Citations
    class BookTitleAutoTextField < PublicationTitleAutoTextField
      def initialize options
        @attribute_path = 'book_title'
        super
      end
    end
  end
end
