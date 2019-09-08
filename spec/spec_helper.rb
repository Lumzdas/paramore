# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require_relative '../lib/paramore'
require_relative 'formatters/int'
require_relative 'formatters/int_array'
require_relative 'formatters/text'

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
