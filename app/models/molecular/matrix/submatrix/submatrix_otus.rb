class Molecular::Matrix::Submatrix::SubmatrixOtus < ActiveRecord::Base
  self.table_name = "molecular_matrix_submatrix_otus"

  has_one :submatrix
  belongs_to :otu

  acts_as_list :scope => :submatrix
  scope :in_list, includes(:otu).where(:position ^ nil).order(:position)
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17

  def self.sorted_by_cells(submatrix)
    timeline = submatrix.timeline
    sql = %(
      SELECT so.*, coalesce(mc_count.cells_count,0) as cells_count, coalesce(mc_seq_count.seq_count,0) as seq_count
        FROM molecular_matrix_submatrix_otus as so
          LEFT OUTER JOIN
            (
              SELECT otu_id, count(otu_id) as cells_count
              FROM mol_matrix_cells
              WHERE timeline_id = #{timeline.id}
                    and is_active = true
                    and marker_id in (#{submatrix.markers.map{|m|m.id}.join(',')})
              GROUP BY otu_id
            ) as mc_count
            ON so.otu_id = mc_count.otu_id
          LEFT OUTER JOIN
            (
              SELECT otu_id, sum(sequence_count) as seq_count
              FROM mol_matrix_cells
              WHERE timeline_id = #{timeline.id}
                    and is_active = true
                    and otu_id in (#{submatrix.otus.map{|o|o.id}.join(',')})
              GROUP BY otu_id
            ) as mc_seq_count
            ON so.otu_id = mc_seq_count.otu_id
        WHERE so.submatrix_id = #{submatrix.id}
        ORDER BY cells_count DESC NULLS LAST, seq_count DESC NULLS LAST, so.position;
    )
    Molecular::Matrix::Submatrix::SubmatrixOtus.find_by_sql(sql)
  end

end