class CitationsParser::Author
  #need to improve this function being used also from people_controller
  def self.extract_firstlast_names(name, splitter=',')
    temp = name.split(splitter)
    if temp.size>0
      case temp.size
        when 1
        #return {:last_name => temp[0].strip.downcase}
        return {:name => temp[0].strip.downcase}
        when 2
        #return {:last_name => temp[0].strip.downcase, :first_name => temp[1].strip.downcase}
        return {:name => temp[0].strip.downcase + ', ' + temp[1].strip.downcase}
        when 3
        #return {:last_name => temp[0].strip.downcase, :first_name => temp[1].strip.downcase, :middle_name => temp[2].strip.downcase}
        return {:name => temp[0].strip.downcase + ', ' + temp[1].strip.downcase + ' ' + temp[2].strip.downcase}
      else
        #return {:last_name => temp[0].strip.downcase}
        return {:name => temp[0].strip.downcase}
      end
    end
  end

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
  def first_name
    @first_name
  end
  def last_name
    last_name
  end
end