class Molecular::Matrix::MatricesMarkers < ActiveRecord::Base
  self.table_name = 'mol_matrices_markers'

  #belongs_to :matrix_checkpoint, :class_name => "Molecular::Matrix::Checkpoint", :foreign_key => 'checkpoint_id'
  belongs_to :marker,
             :class_name => 'Molecular::Marker',
             :foreign_key => 'marker_id'

  belongs_to :timeline,
             :class_name => "Molecular::Matrix::Timeline",
             :foreign_key => "timeline_id"

  acts_as_list :scope => :timeline
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17
  scope :in_list, includes(:marker).where(:position ^ nil).order(:position)

  before_create :set_create_date
  before_save   :update_timeline_date

  def remove_from_list
    self.delete_date = DateTime.now.utc
    super
  end

  def self.find_by_timeline_and_marker(timeline,marker)
    results = Molecular::Matrix::MatricesMarkers.where('timeline_id = ? and marker_id = ? and position is not null', timeline.id, marker.id)
    results.empty? ? nil : results.first
  end

  def for_date(date)
    self.where('create_date <= ? and (delete_date >= ? or delete_date is null)', date, date)
  end

  def self.for_timeline_and_date(timeline, date)
      Molecular::Matrix::MatricesMarkers.where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', timeline, date, date)
  end

  private
  def set_create_date
    self.create_date = DateTime.now.utc
  end

  def update_timeline_date
    self.timeline.updated_at = DateTime.now.utc
  end

end
