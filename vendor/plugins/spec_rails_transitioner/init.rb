#require 'rspec'
#
## TRANSITIONAL - REMOVE ONCE RAILS 3 HAS BEEN INSTALLED
#module Spec
#  module Runner
#    class << self
#      def configure *args
#
#      end
#    end
#  end
#  module Matchers
#    class Change
#      def evaluate_value_proc
#      end
#    end
#  end
#  class Example
#    class ExampleGroupFactory
#      class << self
#        def register *args
#
#        end
#        def default *args
#
#        end
#      end
#    end
#  end
#  module Rails
#    module Example
#      class FunctionalExampleGroup < ActionController::TestCase
#
#      end
#      class HelperExampleGroup < FunctionalExampleGroup
#        class << self
#          def before *args
#
#          end
#        end
#      end
#      class IntegrationExampleGroup < ActionController::IntegrationTest
#        RSpec.configure do |c|
#          c.extend self, :example_group => { :file_path => /\bspec\/integration\// }
#        end
#      end
#      class ViewExampleGroup < FunctionalExampleGroup
#        class << self
#          def before *args
#
#          end
#
#          def after *args
#
#          end
#        end
#      end
#      class ControllerExampleGroup < FunctionalExampleGroup
#        class << self
#          def before *args
#
#          end
#        end
#      end
#    end
#  end
#end
#module Test
#  module Unit
#    class TestCase
#      class << self
#        def prepend_before *args
#
#        end
#        def append_after *args
#
#        end
#      end
#    end
#  end
#end