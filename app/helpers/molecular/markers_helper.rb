module Molecular::MarkersHelper

  def empty_markers_row
    "<tr><td class='b' colspan='5'>No markers present</td></tr>"
  end

  def marker_seq_connections_link(marker)
    "[<a class='marker_seqs_connections' data-marker-id='#{marker.id}' href='#'>#{marker.seqs.length}</a>]"
  end

  def marker_primer_connections_link(marker)
    "[<a class='marker_primers_connections' data-marker-id='#{marker.id}' href='#'>#{marker.primers.length}</a>]"
  end

  def marker_timeline_connections_link(marker)
    "[<a class='marker_timelines_connections' data-marker-id='#{marker.id}' href='#'>#{marker.timelines.length}</a>]"
  end

  def marker_type_select
    options = ActiveRecord::Base.connection.execute("SELECT distinct type from mol_markers").to_a.map{|kv|kv.values}.flatten
    select("marker","type", options)
  end

end