  module Library
    module Citations
      class JournalTitleAutoTextField < PublicationTitleAutoTextField
        def initialize options
          @attribute_path = 'journal_title'
          super
        end
      end
    end
  end
