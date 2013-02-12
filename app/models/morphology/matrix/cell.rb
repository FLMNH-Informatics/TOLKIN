class Morphology::Matrix::Cell < ActiveRecord::Base
  self.table_name = 'morphology_matrix_cells'

  belongs_to :otu

  belongs_to :character,
             :class_name => 'Morphology::Character'

  belongs_to :matrix_timeline,
             :class_name => 'Morphology::Matrix::Timeline',
             :foreign_key => 'timeline_id'

  belongs_to :creator, :class_name => 'User'

  has_and_belongs_to_many :citations,
                          :class_name => 'Library::Citation',
                          :join_table => 'morphology_matrix_cell_citations',
                          :foreign_key => 'cell_id'

  #belongs_to :status, :class_name => "Morphology::Matrix::Cell::Status"

  #images=====================================================
  has_many :cell_images, class_name: 'ImageJoin', as: :object
  has_many :images, :through => :cell_images
  #===========================================================
  before_save :update_timeline_date
  before_create :set_initial_values

  def timeline
    self.matrix_timeline
  end

  def codings
    self.state_codings
  end

  def info_attributes
    {
      "character_id"   => self.character_id,
      "otu_id"         => self.otu_id,
      "state_codings"  => self.state_codings,
      "status"         => self.status,
      "notes"          => self.notes,
      "timeline_id"    => self.timeline_id,
      "is_active"      => true
    }
  end

  def update_timeline_date
    self.matrix_timeline.update_attributes!({:updated_at => Time.now.utc}) unless self.matrix_timeline.nil?
  end

  def set_initial_values
    self.create_date = DateTime.now.utc
  end

  def overwrite(attrs = {})
    self.mark_overwritten
    new_cell = Morphology::Matrix::Cell.create!(self.info_attributes.merge(attrs))
    self.images.each{|img| new_cell.images << img }
    self.citations.each{|citation| new_cell.citations << citation}
    new_cell
  end

  def mark_overwritten
    self.is_active = false
    self.overwrite_date = DateTime.now.utc
    self.save!
  end

  def self.find_with_characters_and_otus(matrices_characters,matrices_otus)
    #todo
  end

  def self.find_by_timeline_and_date(timeline, date = Time.now.utc)
    date = date.utc
    cell_sql_query = "
      select cells.* from
        (select *,
               rank() OVER (PARTITION BY otu_id, character_id order by create_date desc) as the_rank
        from morphology_matrix_cells
        where
          timeline_id = #{timeline.id} and
          create_date <= timestamp '#{date}'
        ) as cells
      INNER JOIN
        morphology_matrices_characters chrs
          on (cells.character_id = chrs.character_id and
              cells.timeline_id = chrs.timeline_id)
      INNER JOIN
        morphology_matrices_otus otus
          on (cells.otu_id = otus.otu_id and
              cells.timeline_id = otus.timeline_id)
      WHERE
        cells.timeline_id = #{timeline.id} and
        cells.create_date <= timestamp '#{date}' and
        (cells.overwrite_date >= timestamp '#{date}' or cells.overwrite_date is null) and
        otus.create_date <= timestamp '#{date}' and
        (otus.delete_date is null or otus.delete_date >= timestamp '#{date}') and
        chrs.create_date <= timestamp '#{date}' and
        (chrs.delete_date is null or chrs.delete_date >= timestamp '#{date}') and
        the_rank = 1
      ORDER BY
        otus.position, otus.delete_date, chrs.position, chrs.delete_date;
    "
    self.find_by_sql(cell_sql_query)
  end

  def project
    self.timeline.matrix.project
  end

  def matrix
    self.timeline.matrix
  end

  def copy(scope = nil)
    cell = Morphology::Matrix::Cell.new(
      :create_date               => DateTime.now.utc,
      :is_active                 => true,
      :character_id              => scope.nil? ? self.character_id : self.character.equivalent_in(scope.characters).id,
      :otu_id                    => self.otu_id,
      :notes                     => self.notes,
      :state_codings             => self.state_codings,
      :status                    => self.status
    )
    cell.images = self.images
    cell.citations = self.citations
    cell.save!
    cell
  end

  def add_citations(ids)
    self.transaction do
      existing_ids = self.citations.map{ |citations| citations.id.to_s }
      (ids - existing_ids).each{ |id| self.citations << self.project.citations.find(id) || fail('could not add citation')  }
    end
  end

end