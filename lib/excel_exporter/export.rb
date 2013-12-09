require 'spreadsheet'

class ExcelExporter::Export
  def initialize

  end

  def self.to_excel recs, column_names

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'tolkin export'
    to_exclude = %w(rtid owner_graph_rtid)
    rownum = 0
    column_names.each do |col|
      sheet1.row(rownum).push col unless to_exclude.include? col
    end

    recs.each do |rec|
      rownum += 1
      column_names.each do |col|
        unless to_exclude.include? col
          if col.include?('taxon_id') && rec.class != Taxon
            sheet1.row(rownum).push rec.try(col.gsub('_id', '')).try(:name)
          else
            sheet1.row(rownum).push rec.send(col)
          end
        end
      end
    end
    path = "#{Rails.root}/private/tmp/tolkin_report.xls"
    book.write path
    return path
  end
end