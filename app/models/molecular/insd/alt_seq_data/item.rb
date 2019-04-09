class Molecular::Insd::AltSeqData::Item < ActiveRecord::Base
  belongs_to :alt_seq_data, class_name: 'Insd::AltSeqData'
end