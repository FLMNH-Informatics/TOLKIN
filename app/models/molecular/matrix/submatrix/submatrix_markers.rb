class Molecular::Matrix::Submatrix::SubmatrixMarkers < ActiveRecord::Base
  self.table_name = "molecular_matrix_submatrix_markers"

  has_one :submatrix
  belongs_to :marker,
            :class_name => 'Molecular::Marker',
            :foreign_key => 'marker_id'

  acts_as_list :scope => :submatrix
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17
  scope :in_list, includes(:marker).where(:position ^ nil).order(:position)


  def self.sorted_by_cells(submatrix)
    timeline = submatrix.timeline
    sql = %(
      SELECT sm.*, coalesce(mc_count.cells_count,0) as cells_count, coalesce(mc_seq_count.seq_count,0) as seq_count
        FROM molecular_matrix_submatrix_markers as sm
          LEFT OUTER JOIN
            (
              SELECT marker_id, count(marker_id) as cells_count
              FROM mol_matrix_cells
              WHERE timeline_id = #{timeline.id}
                    and is_active = true
                    and otu_id in (#{submatrix.otus.map{|o|o.id}.join(',')})
              GROUP BY marker_id
            ) as mc_count
            ON sm.marker_id = mc_count.marker_id
          LEFT OUTER JOIN
            (
              SELECT marker_id, sum(sequence_count) as seq_count
              FROM mol_matrix_cells
              WHERE timeline_id = #{timeline.id}
                    and is_active = true
                    and marker_id in (#{submatrix.markers.map{|m|m.id}.join(',')})
              GROUP BY marker_id
            ) as mc_seq_count
            ON sm.marker_id = mc_seq_count.marker_id
      WHERE sm.submatrix_id = #{submatrix.id}
      ORDER BY cells_count DESC NULLS LAST, seq_count DESC NULLS LAST, sm.position;
    )
    Molecular::Matrix::Submatrix::SubmatrixMarkers.find_by_sql(sql)
  end
end