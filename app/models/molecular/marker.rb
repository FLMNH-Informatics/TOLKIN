class Molecular::Marker < ActiveRecord::Base
  self.table_name = 'mol_markers'

  belongs_to :project

  belongs_to :creator, :class_name => "User"

  has_many :seqs,
           :through => :seq_markers

  has_many :seq_markers,
           :class_name => "Molecular::Insd::Seq::SeqMarker",
           :foreign_key => "marker_id"

  has_many :timelines,
           :through => :matrices_markers

  has_many :matrices_markers,
           :class_name => "Molecular::Matrix::MatricesMarkers",
           :foreign_key => "marker_id"

  has_many :cells,
           :class_name => "Molecular::Matrix::Cell",
           :foreign_key => "marker_id"

  has_many :primers,
           :class_name => "Molecular::Primer",
           :foreign_key => "marker_id"

  before_save :lower_marker_name, :name_from_lower_name
  before_save :cascade_sequence_marker_fulltext

  scope :for_project, lambda { |project| { :conditions => ["project_id = ?", project.project_id], :order => 'lower_name, type desc' } }
  #scope :for_timeline, lambda {|timeline|{ :conditions => {:cells => ['timeline_id', timeline.id]}}}

  def self.find_or_create_by_project_and_name(project,name)
    marker = Molecular::Marker.where(:project_id => project.project_id, :lower_name => name.downcase).first || project.markers.create!({:name => name, :lower_name => name.downcase, })
    marker
  end

  def lower_marker_name
    self.lower_name = self.name.downcase unless self.name.nil?
  end

  def name_from_lower_name
    self.name = self.lower_name if self.name.nil?
  end

  def cascade_sequence_marker_fulltext
    self.sequences.each{ |seq| seq.update_markers_fulltext }
  end

  def sequences
    self.seqs
  end

  def merge(marker)
    Molecular::Marker.transaction do
      #merge sequences
      marker.seq_markers.each { |sm| sm.update_attributes(:marker_id => self.id) }
      #merge matrices
      marker.matrices_markers.each { |mm| mm.update_attributes(:marker_id => self.id) }
      #merge cells
      marker.cells.each { |cm| cm.update_attributes(:marker_id => self.id) }
      #merge primers
      marker.primers.each { |pm| pm.update_attributes(:marker_id => self.id) }
      marker.reload
      marker.destroy!
      self.save
    end
    self
  end

  def destroy!
    Molecular::Marker.transaction do
      self.seq_markers.each{|sm| sm.destroy }
      self.matrices_markers.each{|mm| mm.destroy }
      self.cells.each{|cm| cm.destroy }
      self.destroy
    end
  end

  #def self.add_to_matrix matrix, options = { }
  #  if options[:name] && !matrix.markers.select{ |cur_marker| cur_marker.name == options[:name] }.empty?
  #    raise "Marker not added. Marker '#{options[:name]}' has the same name as another marker in the matrix."
  #  end
  #  Molecular::Marker.transaction do
  #      @marker = matrix.project.markers.find_by_name options[:name]
  #      @marker = matrix.project.markers.create! :name => options[:name] unless @marker
  #      matrix.changeset.items.create! :change_type => ChangeTypes::ADD, :new_version => @marker
  #      matrix.markers << @marker
  #  end
  #@marker
  #end
  #
  #def checkpoint_add(checkpoint)
  #  checkpoint.matrices_markers.create!(:marker => self)
  #end
  #
  ## be careful with this! intended only to be used for committing
  #def checkpoint_remove(checkpoint)
  #  checkpoint.matrices_markers.find_by_marker_id(self.id).destroy
  #end
  #
  #def checkpoint_move(checkpoint, prev_position, next_position, should_swap)
  #    move_item = Molecular::Matrix::MatricesMarkers.find_by_checkpoint_id_and_marker_id(checkpoint.id, self.id)
  #    prev_item = should_swap ? Molecular::Matrix::MatricesMarkers.find_by_matrix_id_and_position(checkpoint.id, next_position) : nil
  #    prev_item.insert_at(prev_position) if prev_item
  #    move_item.insert_at(next_position)
  #end

  def to_s
    self.name
  end
end
