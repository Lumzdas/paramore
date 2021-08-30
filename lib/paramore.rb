require_relative 'paramore/configuration'
require_relative 'paramore/railtie'
require_relative 'paramore/types'
require_relative 'paramore/field_schema'

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
    Paramore::FieldSchema.new(
      given_type,
      **Paramore::FieldSchema::DEFAULT_OPTIONS.merge(options)
    )
  end
end
