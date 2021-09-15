require_relative 'paramore/configuration'
require_relative 'paramore/railtie'
require_relative 'paramore/types'
require_relative 'paramore/field'

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

  def self.field(given_type, options = {})
    Paramore::Field.new(
      given_type,
      **Paramore::Field::DEFAULT_OPTIONS.merge(options)
    )
  end
end
