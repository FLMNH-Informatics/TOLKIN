# 2010.11.02 - ChrisG - 4 lines added to pass controller along
# to component will need to be checked again with each new
# version of netzke released.
#require 'netzke-core'
#
#debugger
#ActiveSupport.on_load('action_view') do
#  debugger
#  def netske(name, config = {})
#    debugger
#    puts 'oink!'
#    config[:controller] = controller
#    super
#  end
#end
#
#module Netzke
#  class Base
#    def initialize(conf = {}, parent = nil)
#      debugger
#      @controller = conf.delete(:controller) # LINE ADDED
#      @passed_config = conf # configuration passed at the moment of instantiation
#      @passed_config.deep_freeze
#      @parent = parent
#      @name = conf[:name].nil? ? short_component_class_name.underscore : conf[:name].to_s
#      @global_id = parent.nil? ? @name : "#{parent.global_id}__#{@name}"
#      @flash = []
#
#      # initialize @components and @items
#      normalize_components_in_items
#      # auto_collect_actions_from_config_and_js_properties
#    end
#
#    def controller # LINE ADDED
#      @controller # LINE ADDED
#    end # LINE ADDED
#  end
#end