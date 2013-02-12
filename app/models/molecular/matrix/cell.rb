class Molecular::Matrix::Cell < ActiveRecord::Base

  belongs_to :marker,           :class_name => 'Molecular::Marker'
  belongs_to :otu
  has_and_belongs_to_many :sequences,
    :class_name => 'Molecular::Insd::Seq',
    join_table: 'mol_matrix_cell_sequences',
    foreign_key: 'cell_id',
    association_foreign_key: 'seq_id'
  belongs_to :matrix_timeline,  :class_name => 'Molecular::Matrix::Timeline',              :foreign_key => 'timeline_id'
  belongs_to :creator,          :class_name => 'User'
  belongs_to :responsible_user, :class_name => 'User'
  belongs_to :primary_sequence, :class_name => 'Insd::Seq'
  belongs_to :status,           :class_name => 'Molecular::Matrix::Cell::Status'

  self.table_name = 'mol_matrix_cells'

  before_save :check_for_primary
  before_save :get_user_initials
  before_save :check_and_get_primary_sequence_locus
  before_save :count_all_sequences
  before_save :get_status
  before_save :update_timeline_date
  before_create :mark_active

  default_scope include: :status # default scope needs to be active always for matrix show display

  def mark_active
    self.create_date = DateTime.now.utc
    self.is_active   = true
  end

  def copy
    Molecular::Matrix::Cell.create!(
      :create_date               => DateTime.now.utc,
      #:creator_id                => current_user.user_id,
      :is_active                 => true,
      :marker_id                 => self.marker_id,
      :otu_id                    => self.otu_id,
      :notes                     => self.notes,
      :primary_sequence_id       => self.primary_sequence_id,
      :primary_sequence_locus    => self.primary_sequence_locus,
      :responsible_user_id       => self.responsible_user_id,
      :responsible_user_initials => self.responsible_user_initials,
      :sequence_count            => self.sequence_count,
      :status_id                 => self.status_id,
      :sequences                 => self.sequences
    )
  end

  def overwrite
    self.is_active = false
    self.overwrite_date = Time.now.utc
    self.save!
    self.reload
    Molecular::Matrix::Cell.new({ :otu_id => self.otu_id,
                                  :marker_id => self.marker_id,
                                  :timeline_id => self.timeline_id,
                                  :create_date => Time.now.utc,
                                  :is_active => true,
                                  :sequences => self.sequences})
  end

  def self.find_or_create_by_timeline_otu_marker(timeline,otu,marker)
    cell = Molecular::Matrix::Cell.where({:matrix_timeline => timeline,
                                         :otu => otu,
                                         :marker => marker,
                                         :overwrite_date => nil
    }).first.try(:overwrite) || Molecular::Matrix::Cell.create!({:matrix_timeline => timeline, :otu => otu, :marker => marker })
    cell
  end

  def self.find_by_timeline_and_date_and_markers(timeline, date = Time.now, markers)
    date = date.utc
    marker_sql = markers.empty? ? '' : " JOIN (
      values
      #{timeline.matrices_markers
          .where('create_date <= ? and (delete_date >= ? or delete_date is null)', date)
          .order('position')
          .paginate(:page => params[:page], :per_page => 15, :order => 'position')
          .collect{|m| [m.marker_id, m.position]}.to_s.gsub('[','(').gsub(']',')')[1..-2]
      }) as markers (id, ordering) on cells.marker_id = markers.id
    "
    otu_sql = timeline.matrices_otus.where('create_date <= ? and (delete_date >= ? or delete_date is null)', date).empty? ? '' : " JOIN (
      values
      #{timeline.matrices_otus
          .where('create_date <= ? and (delete_date >= ? or delete_date is null)', date)
          .order('position')
          .collect{|mo|[mo.otu_id, mo.position]}
          .to_s.gsub('[','(').gsub(']',')')[1..-2]
      }) as otus (id, ordering) on cells.otu_id = otus.id
    "
    otus_ordering = timeline.matrices_otus.for_date(date).emtpy? ? '' : ' otus.ordering'
    markers_ordering = timeline.matrices_markers.for_date(date).emtpy? ? '' : ' markers.ordering'
    order_by = (timeline.matrices_otus.for_date(date).empty? && timeline.matrices_markers.for_date(date).empty?) ? "" : " ORDER BY "
    comma = (!timeline.matrices.otus.for_date(date).empty? && !timeline.matrices_markers.for_date(date).emtpy?) ? "," : ""
    sql = "
      SELECT cells.* from mol_matrix_cells cells
      " + marker_sql + " " + otu_sql + "
      WHERE
        cells.timeline_id = #{timeline.id} and
        cells.create_date <= timestamp '#{date}' and
        (cells.overwrite_date >= timestamp '#{date}' or cells.overwrite_date is null)
    " + order_by + otus_ordering + comma + markers_ordering + ";"
    Molecular::Matrix::Cell.find_by_sql(sql)
  end

  def self.find_by_timeline_and_date(timeline, date = Time.now.utc)
    date = date.utc
    cell_sql_query = "
      select cells.* from
        (select *,
               rank() OVER (PARTITION BY otu_id, marker_id order by create_date desc) as the_rank
        from mol_matrix_cells
        where
          timeline_id = #{timeline.id} and
          create_date <= timestamp '#{date}'
        ) as cells
      INNER JOIN
        mol_matrices_markers mrks
          on (cells.marker_id = mrks.marker_id and
              cells.timeline_id = mrks.timeline_id)
      INNER JOIN
        mol_matrices_otus otus
          on (cells.otu_id = otus.otu_id and
              cells.timeline_id = otus.timeline_id)
      WHERE
        cells.timeline_id = #{timeline.id} and
        cells.create_date <= timestamp '#{date}' and
        (cells.overwrite_date >= timestamp '#{date}' or cells.overwrite_date is null) and
        otus.create_date <= timestamp '#{date}' and
        (otus.delete_date is null or otus.delete_date >= timestamp '#{date}') and
        mrks.create_date <= timestamp '#{date}' and
        (mrks.delete_date is null or mrks.delete_date >= timestamp '#{date}') and
        the_rank = 1
      ORDER BY
        otus.position, mrks.position;
    "
    self.find_by_sql(cell_sql_query)
  end

  def force_primary_sequence
    self.primary_sequence || self.sequences.first
  end

  def seqs
    self.sequences
  end

  def update_timeline_date
    self.matrix_timeline.update_attributes!({:updated_at => Time.now.utc}) unless self.matrix_timeline.nil?
  end

  def remove_seq(seq)
    self.sequences.delete(seq)
    self[:primary_sequence_id] = nil if self[:primary_sequence_id].to_s == id
  end

  def make_primary(id)
    self.primary_sequence = Molecular::Insd::Seq.find(id) unless id.nil? || id.blank?
  end

  private

  def count_all_sequences
    self.sequence_count = self.sequences.length
  end

  def check_for_primary
    if self.sequences.empty?
      self.primary_sequence_id = nil
    elsif self.primary_sequence.nil? || self.primary_sequence_id.blank?
      self.primary_sequence = self.sequences.first
    end
  end

  def update_primary_info
    #todo: do it
  end

  def get_user_initials
    unless self.responsible_user.nil? || self.responsible_user.initials.nil?
      self.responsible_user_initials = self.responsible_user.initials unless self.responsible_user_initials == self.responsible_user.initials
    end
  end

  def check_and_get_primary_sequence_locus
    if self.primary_sequence.nil?
      self.primary_sequence_locus = nil
    else
      unless self.primary_sequence.locus.nil?
        self.primary_sequence_locus = self.primary_sequence.locus unless self.primary_sequence_locus == self.primary_sequence.locus
      end
    end
  end

  def get_status
    self.status_text = self.status ? self.status.name : "Incomplete"
  end

end
