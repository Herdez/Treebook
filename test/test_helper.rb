ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  include FactoryGirl::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers

  def self.context *args, &block
    super *args do
      setup do
        # establish the rails controller being tested
        # https://github.com/citrusbyte/contest/issues/5#issuecomment-677003
        ancestors = self.class.ancestors
        test_case = ancestors[ancestors.index(ActionController::TestCase) - 1]
        @controller = test_case.controller_class.new
      end
      #class_eval &block
    end
  end
  
end
