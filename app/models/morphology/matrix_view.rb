class Morphology::MatrixView < ActiveRecord::Base
  include GenericSearch

  belongs_to :project

  self.table_name = 'morphology_matrix_view'

  def self.searchable_columns
    @searchable_columns ||= [
        'name',
        'created_by',
        'updated_by'
      ].collect { |col_name|
        column = columns_hash[col_name] || columns_hash["#{col_name}_id"]
        {"name" => column.name, "type" => column.type.to_s }
      }
  end
end
