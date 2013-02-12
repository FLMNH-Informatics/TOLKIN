class Molecular::Insd::Seqs::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    options = { buttons: [ { label: 'Create',               img: { src: '/images/small_addnew.gif' } },
                           { label: 'Import from FASTA',    img: { src: '/images/sm_upload.png'    } },
                           { label: 'Delete',               img: { src: '/images/small_cross.png'  } },
                           { label: 'Export FASTA',         img: { src: '/images/small_import.png' } },
                           { label: 'Create alignment',     img: { src: '/images/align16.png'      } },
                           { label: 'Edit FASTA Sequences', img: { src: '/images/small_addnew.gif' } }
                         ]}.merge(options)
    super
    if interact_mode != 'edit'
      @buttons = {}
    end
  end
end
