class Hash
  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = 
        if tv.is_a?(Hash) && v.is_a?(Hash)
          tv.deep_merge(v)
        elsif tv.is_a?(Array) && v.is_a?(Array)
          #FIXME: below is horrible. Hash needs to be subclassed specifically for activerecord and have its own custom deep_merge function
          (tv.empty? ? tv + ['*'] : tv) + v  # Warning: activerecord specific.  You are screwed if you are using this for anything else.
        else
          v
        end
    end
    self
  end
end