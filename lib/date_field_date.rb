class DateFieldDate
  def initialize date
    @date = date
  end

  def Y
    @date[:Y]
  end

  def mm
    @date[:mm]
  end

  def dd
    @date[:dd]
  end

end
