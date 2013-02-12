class String
  def to_b
    if self.match(/^t(rue)?$/i)
      true
    elsif self.match(/^f(alse)?$/i)
      false
    else
      fail("you're using this wrong: please only use 'true' or 'false' strings")
    end
  end
end