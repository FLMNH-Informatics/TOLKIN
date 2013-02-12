#class Molecular::Matrix::Cell::Sequence < ActiveRecord::Base
#  belongs_to :cell, :class_name => 'Molecular::Matrix::Cell'
#  belongs_to :bioentry, :class_name => 'Molecular::Bioentry'
#  has_one :biosequence, :class_name => 'Molecular::Biosequence', :foreign_key => 'bioentry_id', :primary_key => 'bioentry_id'
#  belongs_to :seqfeature, :class_name => 'Molecular::Seqfeature'
#
#  def create_clone(attributes = nil)
#    new_sequence = self.clone
#    new_sequence.update_attributes!(attributes) unless attributes.nil?
#    new_sequence
#  end
#
#  def destroy_for(user, address)
#    self.cell.editable_for(user, address).sequences.find_by_bioentry_id(self.bioentry_id).destroy
#  end
#
#  def accession
#    bioentry.try(:accession)
#  end
#
#  def accession_and_primary
#    cell.primary_sequence == self ? "#{accession} (primary)" : accession.to_s
#  end
#
#  def description
#    bioentry.try(:description)
#  end
#
#  def length
#    seqfeature.try(:length) || biosequence.length
#  end
#
#  def seq
#    seqfeature.try(:seq) || biosequence.seq
#  end
#
##  def to_json
##    { :sequence => {
##        :accession => accession,
##        :description => description,
##        :length => length,
##        :seq => seq
##      }
##    }.to_json
##  end
#
#  private
#
#  def before_destroy
#    self.cell.change_item.add_note("removed sequence #{self.accession}", User.AUTOMATED)
#  end
#end
