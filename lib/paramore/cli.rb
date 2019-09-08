# frozen_string_literal: true

module Paramore
  module Cli
    module_function
    def config!
      config_file_path = 'config/initializers/paramore.rb'

      if File.exists?(config_file_path)
        puts "#{config_file_path} already exists, skipping"
        exit 0
      end

      File.write(config_file_path, <<~CONF)
        # frozen_string_literal: true

        Paramore.configure do |config|
          # change this to any level you need, eg.: `'A::B'` for doubly nested formatters
          # or `nil` for top level formatters
          # config.formatter_namespace = 'Formatter'

          # what method name to call formatters with
          # config.formatter_method_name = 'run'
        end
      CONF

      puts "#{config_file_path} created"
    end
  end
end
