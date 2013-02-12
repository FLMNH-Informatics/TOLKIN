class Molecular::Matrix::Timeline < ActiveRecord::Base

  has_many :matrices_markers,
           :class_name  => "Molecular::Matrix::MatricesMarkers",
           :foreign_key => "timeline_id",
           :order       => "position"

  has_many :markers,
           :through     => :matrices_markers,
           :class_name  => "Molecular::Marker"

  has_many :matrices_otus,
           :class_name  => "Molecular::Matrix::MatricesOtus",
           :foreign_key => "timeline_id"#,
           #:order       => "position"

  has_many :otus,
           :through => :matrices_otus

  has_many :cells,
           :class_name  => "Molecular::Matrix::Cell",
           :foreign_key => 'timeline_id',
           :conditions  => {:is_active => true}

  has_many :alignments,
           :class_name  => "Molecular::Alignment",
           :foreign_key => "timeline_id"

  has_many :molecular_matrices_otu_groups,
           :class_name  => "Molecular::Matrix::MolecularMatricesOtuGroups",
           :foreign_key => "matrix_timeline_id"

  belongs_to :matrix,
             :class_name  => "Molecular::Matrix",
             :foreign_key => "matrix_id"


  #belongs_to :project

  self.table_name = 'molecular_matrix_timelines'

  def mark_deleted
    self.delete_date = DateTime.now()
    self.save!
  end

  def project
    self.matrix.project
  end

  def active_markers
    Molecular::Marker.joins(:matrices_markers).where({:matrices_markers => {:delete_date => nil, :timeline_id => self.id}})
  end

  def active_otus
    Otu.joins(:matrices_otus).where({:matrices_otus => {:delete_date => nil, :timeline_id => self.id}})
  end

  def self.create_first(matrix, timeline)
    Molecular::Matrix::Timeline.transaction do
      new_matrix = Molecular::Matrix.new(matrix)
      new_matrix.save!
      new_timeline = Molecular::Matrix::Timeline.create!(timeline)
      new_matrix.timelines << new_timeline
      new_matrix.save!
      new_timeline.save!
    end
  end

  def autofill(status_id)
    self.update_attributes(:editable => false)
    status = Molecular::Matrix::Cell::Status.find(status_id)
    otus_markers = self.active_otus.product(self.active_markers)
    otus_markers.each do |otu_marker|
      otu, marker = otu_marker.first, otu_marker.last
      seqs = *Molecular::Insd::Seq.from_project_with_marker_and_otu(self.project,marker,otu)
      unless seqs.empty?
        cell = Molecular::Matrix::Cell.find_or_create_by_timeline_otu_marker(self,otu,marker)
        if cell.sequences.empty?
          cell.sequences = seqs
          cell.status = status
          cell.save
        elsif cell.sequences.length != seqs.length
          cell.sequences = cell.sequences | seqs
          cell.status = status
          cell.save
        else
          cell.sequences = cell.sequences | seqs
          cell.status = status
          cell.save
        end
      end
    end
    self.update_attributes(:editable => true)
    self
  end

  def project_id
    self.matrix.project_id
  end

  def create_next_version
    self.get_objs_by_date
    new_timeline = Molecular::Matrix::Timeline.new(
      :description => self.description,
      :matrix_id   => self.matrix.id
    )
    @otus.each{ |otu| new_timeline.otus << otu }
    @markers.each{ |marker| new_timeline.markers << marker}
    @cells.each { |cell| new_timeline.cells << cell.copy }
    new_timeline.save!
    new_timeline
  end

  def get_objs_by_date(date = DateTime.now.utc)
    date = date.utc
    @matrices_markers = Molecular::Matrix::MatricesMarkers.includes(:marker).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', self.id, date, date).order('position')
    @matrices_otus    = Molecular::Matrix::MatricesOtus.includes(:otu).where('timeline_id = ? and create_date <= ? and (delete_date >= ? or delete_date is null)', self.id, date, date).order('position')
    @cells = Molecular::Matrix::Cell.find_by_timeline_and_date(self, date)
    @markers = @matrices_markers.map{|mmarker|mmarker.marker}
    @otus = @matrices_otus.map{|motu|motu.otu}
  end

  def copy(date = DateTime.now())
    self.get_objs_by_date(date.utc)
    new_matrix = Molecular::Matrix.new(
      :name => "[copy]" + self.matrix.name + "[" + date.to_s(:short) + "]",
      :created_at     => DateTime.now.utc,
      :copied_from_id => self.matrix.id)
    new_timeline = Molecular::Matrix::Timeline.create!(
      :description => "Copied from " +
                      (self.matrix.name.nil? ? '[no name]' : self.matrix.name) +
                      " on " + date.to_s(:long) +
                      ". \n" +
                      (self.description.nil? ? '' : self.description)
    )
    new_matrix.timelines << new_timeline
    new_matrix.save!
    @otus.each{ |otu| new_timeline.otus << otu }
    @markers.each{ |marker| new_timeline.markers << marker}
    @cells.each { |cell| new_timeline.cells << cell.copy }
    new_timeline.save!
    new_timeline
  end

  def remove_otu(otu)
    motu = Molecular::Matrix::MatricesOtus.find_by_timeline_and_otu(self, otu)
    motu.remove_from_list
    motu.delete_date = DateTime.now.utc
    motu.save!
  end

  def remove_marker(marker)
    mmarker = Molecular::Matrix::MatricesMarkers.find_by_timeline_and_marker(self, marker)
    mmarker.remove_from_list
    mmarker.delete_date = DateTime.now.utc
    mmarker.save!
  end

  def sorted_versions
    self.matrix.timelines.sort{|a,b| a.updated_at <=> b.updated_at}
  end

  def version_number
    sorted_versions.index(self) + 1
  end

  def number_of_versions
    self.matrix.timelines.length
  end

  def next_version
    self.version_number < self.matrix.timelines.length ? sorted_versions[self.version_number] : nil
  end

  def previous_version
    self.version_number > 1 ? sorted_versions[self.version_number - 2] : nil
  end

  def first_version
    self.is_first_version? ? self : sorted_versions.first
  end

  def last_version
    self.is_last_version? ? self : sorted_versions.last
  end

  def is_last_version?
    self.sorted_versions.last == self
  end

  def is_first_version?
    self.previous_version.nil?
  end

  def empty?
    (self.markers.empty? && self.otus.empty? && self.cells.empty?) ? true : false
  end

  def name
    self.matrix.name.to_s
  end

  def deleted?
    if self.delete_date == nil
      false
    elsif self.delete_date <= DateTime.now.utc
      true
    else
      false
    end
  end

  def timeline_id
    self.id
  end
end