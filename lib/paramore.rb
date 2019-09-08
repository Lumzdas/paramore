# frozen_string_literal: true

require_relative 'paramore/configuration'
require_relative 'paramore/railtie'

module Paramore
  class << self
    attr_reader :configuration
  end

  def self.configuration
    @configuration ||= Paramore::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
