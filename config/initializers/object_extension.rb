class Object
  # turns nil values to empty string
  def nilstring
    self.nil? ? '' : self
  end
end