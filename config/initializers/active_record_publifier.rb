class ActiveRecord::Base

  ######
  # DO NOT DEFINE public_record associations
  # that could override
  # methods defined here
  ######
  attr_accessor :public_record
  #
  after_save :check_public_record
  after_find :set_public_record
  #
  #
  # Add model classes, to this array
  # for any model you want to have
  # the option to make a 
  # PublicRecord for
  ########
  #def self.public_models= pms
  #   public_models = pms
  #end

  def self.public_models
        #NOTE: if adding matrices, make sure to include type::MatrixView ie Molecular::MatrixView as these use sql views for index
    [
     Chromosome::Probe,
     Chromosome::ZFile,
     Collection,
     Molecular::Insd::Seq
    ]
  end
  #
  #
  def public_model?
    self.class.name.constantize.public_models.include?(self.class.name.constantize)
  end
  #
  #
  def self.public_model?
    public_models.include?(self)
  end
  #
  #
  def private_model?
    !self.public_model?
  end
  #
  #
  def self.private_model?
    !public_class?
  end
  #
  #
  # 
  # instance.public_record?
  # alias for instance.public_record
  ########
  def public_record?
    self.public_record
  end
  #
  #
  #
  #
  ########
  def private_record?
    !self.public_record
  end 
  # instance.make_public
  # *chainable*
  # set public_record attr
  # after if statement so we can
  # set it on classes that are related by association
  # to a public class cause chances are that data needs
  # to be public too
  ########
  def make_public
    if self.public_model? && self.is_set?(:project_id)
      pr = {:record_model => self.class.name, :record_id => self.id, :project_id => self.project_id}
      PublicRecord.create(pr)
    end
    self.public_record = true
    self
  end
  alias :publicize :make_public
  #
  #
  #
  #
  # instance.make_private
  # *chainable*
  ########
  def make_private
    if self.public_model? && self.is_set?(:project_id)
      PublicRecord.destroy_all(["record_model = ?  AND record_id = ? AND project_id = ?", self.class.name.to_s, self.id, self.project_id])
    end
    self.public_record = false
    self
  end
  alias :privatize :make_private
  #
  #
  #
  # Instance method returns all records of that class that are public
  # and belong to project of that class if project id is defined
  ########
  def public_records
    # TODO this could use a better AR finder without the need for id array
    if self.public_model? && self.is_set?(:project_id)
      ids = []
      pr = PublicRecord.find_all_by_record_model_and_project_id(self.class.name.to_s, self.project_id)
      pr.each{|p| ids << p.record_id}
      return self.class.name.constantize.find(ids)
    else
      return []
    end
  end
  #
  #
  # ModelName.public_records
  # Class Method version
  # only returns public records of 
  # same class (must be instance to get public records of same project)
  # a convenience method that's probably useless
  ########
  def self.public_records
    ids = []
    pr = PublicRecord.where("record_model = ?", self.to_s )
    pr.each{|p| ids << p.record_id}
    self.find(ids)
  end
  #
  #
  protected
  #
  #
  #
  ########
  def is_set? anything
    self.respond_to?(anything) && self.send(anything) != nil
  end
  #
  #
  private
  #
  #
  #
  ########
  def check_public_record
    if self.public_model?
      if self.public_record == true && !load_public_record
        self.make_public
      end
      #########
      if self.public_record == false && self.respond_to?(:project_id)
        PublicRecord.destroy_all(["record_model = ?  AND record_id = ? AND project_id = ?", self.class.name.to_s, self.id, self.project_id])
      end
    end
  end
  #
  #
  #
  #
  ########
  def set_public_record
    if self.public_model?
      self.public_record = load_public_record
    end
  end
  #
  #
  # 
  # 
  ########
  def load_public_record
    PublicRecord.find_by_record_model_and_record_id(self.class.name,self.id) ? true : false
  end
  #
  #
end