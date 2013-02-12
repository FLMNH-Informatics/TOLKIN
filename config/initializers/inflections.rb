# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /^(\/?tax)on$/i, '\1a' #optional forward slash is a hack to support current check_record_permission in ApplicationController.  Don't remove unless you ensure check_record_permission will still work properly for /taxa.
  inflect.singular /^(\/?tax)a$/i, '\1on'
  inflect.irregular 'matrix', 'matrices'
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
end
