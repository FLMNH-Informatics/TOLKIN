class Exception::HasChildren < Exception
  def initialize object
    super "The object you have tried to delete '#{object.name}' has children.  You must specify what to do with these children."
  end

  def to_hash
    {
      :klass => self.class.to_s,
      :message => message
    }
  end

  def to_json
    to_hash.to_json
  end
end
