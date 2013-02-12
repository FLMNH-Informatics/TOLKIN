class Insd::AltSeqData < ActiveRecord::Base
  self.primary_key = 'pk'
  self.table_name = 'insd_alt_seq_data'

  has_one :seq, class_name: 'Insd::Seq'
  has_many :items, class_name: 'Insd::AltSeqData::Item'

  def destroy
    self.transaction do
      items.each(&:destroy)
      super
    end
  end
end