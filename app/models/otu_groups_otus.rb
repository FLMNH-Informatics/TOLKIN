class OtuGroupsOtus < ActiveRecord::Base
  belongs_to :otu_group
  belongs_to :otu
  acts_as_list :scope => :otu_group
  scope :in_list, includes(:otu).where(:position ^ nil).order(:position)
  default_scope :conditions => (:position ^ nil) #stupid workaround for acts_as_list bug, issue submitted at https://github.com/rails/acts_as_list/issues/17

    def self.find_by_otu_and_otu_group(otu,otu_group)
      results = OtuGroupsOtus.where('otu_id = ? and otu_group_id = ?', otu.id, otu_group.id)
      results.empty? ? nil : results.first
    end

    def self.find_by_otu_group_and_otu(otu_group,otu)
      results = OtuGroupsOtus.where('otu_group_id = ? and otu_id = ?', otu_group.id, otu.id)
      results.empty? ? nil : results.first
    end

    def self.remove_from_list
      super
      self.destroy!
    end
end
