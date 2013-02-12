class Chromosome::Probes::ProbeCatalog < Templates::Catalog
  def initialize options
    options = {columns: [
                          { attribute: 'value',       width: 150 },
                          { attribute: 'scaffold_id', width: 120 },
                          { attribute: 'chromosome',  width: 150 },
                          { attribute: 'genome_builder_super_scaffold',  width: 170 },
                          { attribute: 'probe_type',  width: 100 }
                        ],
               data_id: 'id',
               limit: 10
    }.merge!(options)
    super
  end
end