require 'bundler/setup'
Bundler.setup

require 'combustion'
Combustion.initialize! :action_controller

require 'rspec/rails'

require_relative '../lib/paramore'

require_relative 'types/int'
require_relative 'types/text'
require_relative 'types/typo'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
