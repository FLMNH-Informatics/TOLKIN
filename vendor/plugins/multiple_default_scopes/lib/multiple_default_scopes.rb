module MultipleDefaultScopes
  def self.extended(object)
    class << object
      alias_method :default_scope_without_multiple, :default_scope unless method_defined?(:default_scope_without_multiple)
      alias_method :default_scope, :default_scope_with_multiple
    end
  end

  protected

  def default_scope_with_multiple scoping = {}
    @merged_default_scoping ||= {}
    @merged_default_scoping.deep_merge!(scoping)
    default_scope_without_multiple(@merged_default_scoping)
  end
end