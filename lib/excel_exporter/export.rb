require 'spreadsheet'

class ExcelExporter::Export
  def initialize

  end

  def self.to_excel recs, column_names

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'tolkin export'

    rownum = 0
    column_names.each do |c|
      sheet1.row(rownum).push c
    end

    recs.each do |r|
      rownum += 1
      column_names.each do |c|
        if c.include?('taxon_id')
           sheet1.row(rownum).push r.try(c.gsub('_id', '')).try(:name)
        else
           sheet1.row(rownum).push r.send(c)
        end
      end
    end
    path = "#{Rails.root}/private/tmp/tolkin_report.xls"
    book.write path
    return path
  end
end