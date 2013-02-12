require 'test/unit'
require 'test_helper'


class ProbeTest < ActiveSupport::TestCase
  fixtures :all
  def test_z_files
    probe = probes(:probe_1)
    hybridization = hybridizations(:hybridization_1)
    z_file_ids = probe.z_files.collect(&:id)
    z_file_project_ids =  probe.z_files.collect(&:project_id)
    z_file_zvi_file_names = probe.z_files.collect(&:zvi_file_name)
    z_file_content_types = probe.z_files.collect(&:content_type)
    test_z_file = Chromosome::ZFile.find_by_id(hybridization.z_file_id)
    assert z_file_ids.include?(test_z_file.id)
    assert z_file_project_ids.include?(test_z_file.project_id)
    assert z_file_zvi_file_names.include?(test_z_file.zvi_file_name)
    assert z_file_content_types.include?(test_z_file.content_type)
  end

  def test_dyes
    probe = probes(:probe_1)
    hybridization = hybridizations(:hybridization_1)
    dye_ids = probe.dyes.collect(&:id)
    dye_project_ids = probe.dyes.collect(&:project_id)
    dye_dye_value = probe.dyes.collect(&:dye_value)
    assert dye_ids.include?(Chromosome::Dye.find_by_id(hybridization.dye_id).id)
    assert dye_project_ids.include?(Chromosome::Dye.find_by_id(hybridization.dye_id).project_id)
    assert dye_dye_value.include?(Chromosome::Dye.find_by_id(hybridization.dye_id).dye_value)
  end

end
