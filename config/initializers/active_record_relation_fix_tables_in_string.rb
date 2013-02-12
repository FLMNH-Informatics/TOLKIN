module ActiveRecord
  class Relation
    private
    # ChrisG 5/27/11 - Modified to fix issue with certain LIKE statement chars (such as '.') being interpreted as table names
    def tables_in_string(string)
      return [] if string.blank?
      # always convert table names to downcase as in Oracle quoted table names are in uppercase
      # ignore raw_sql_ that is used by Oracle adapter as alias for limit/offset subqueries
      literals_without_dots(string).scan(/([\.a-zA-Z_]+).?\./).flatten.map{ |s| s.downcase }.uniq - ['raw_sql_']
    end

    def literals_without_dots(string) 
      string.gsub(/(['"])(([^\\]|(\\.))*?)(\1)/) {|s| s.gsub('.', '_')} 
    end
  end
end
