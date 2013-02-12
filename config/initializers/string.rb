class String
  def tooltipify(length=60)
    self.split(/(.{0,#{length}})/).join(" ").lstrip
  end
end