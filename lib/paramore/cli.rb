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
        Paramore.configure do |config|
          # what method name to call types with
          # config.type_method_name = :[]
        end
      CONF

      puts "#{config_file_path} created"
    end
  end
end
