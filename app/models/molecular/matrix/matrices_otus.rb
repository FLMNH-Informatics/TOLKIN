class Molecular::Matrix::MatricesOtus < ActiveRecord::Base
  self.table_name = 'mol_matrices_otus'

  #belongs_to :matrix_checkpoint,
  #           :class_name => "Molecular::Matrix::Checkpoint",
  #           :foreign_key => 'checkpoint_id'

  belongs_to :otu

  belongs_to :timeline,
    :class_name => "Molecular::Matrix::Timeline",
    :foreign_key => "timeline_id"

  #acts_as_list :scope => :checkpoint
  acts_as_list :scope => :timeline
  scope :in_list, includes(:otu).where(:position ^ nil).order(:position)
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17

  before_create :set_create_date
  before_save   :update_timeline_date

  def remove_from_list
    self.delete_date = DateTime.now.utc
    super
  end

  private

  def self.find_by_timeline_and_otu(timeline,otu)
    results = Molecular::Matrix::MatricesOtus.where('timeline_id = ? and otu_id = ?', timeline.id, otu.id)
    results.empty? ? nil : results.first
  end

  def for_date(date)
    self.where('create_date <= ? and (delete_date >= ? or delete_date is null)', date.utc, date.utc)
  end

  def self.for_date(date)
    self.where('create_date <= ? and (delete_date >= ? or delete_date is null)', date.utc, date.utc)
  end

  def self.for_timeline_and_date(timeline, date)
    results = Molecular::Matrix::MatricesOtus.where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', timeline, date.utc, date.utc)
    results.empty? ? [] : results
  end

  def set_create_date
    self.create_date = DateTime.now.utc
  end

  def update_timeline_date
    self.timeline.updated_at = DateTime.now.utc
  end

end
