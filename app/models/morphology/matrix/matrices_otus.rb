class Morphology::Matrix::MatricesOtus < ActiveRecord::Base
  self.table_name = 'morphology_matrices_otus'

  belongs_to :otu

  belongs_to :timeline,
             :class_name  => "Morphology::Matrix::Timeline",
             :foreign_key => "timeline_id"

  acts_as_list :scope => :timeline
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17
  scope :in_list, includes(:otu).where(:position ^ nil).order(:position)


  before_create :set_create_date
  before_save   :update_timeline_date

  def remove_from_list
    self.delete_date = DateTime.now.utc
    super
  end

  private

  def self.find_by_timeline_and_otu(timeline,otu)
    results = Morphology::Matrix::MatricesOtus.where('timeline_id = ? and otu_id = ?', timeline.id, otu.id)
    results.empty? ? nil : results.first
  end

  def set_create_date
    self.create_date = DateTime.now.utc
  end

  def update_timeline_date
    self.timeline.updated_at = DateTime.now.utc
  end

end
