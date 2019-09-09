# frozen_string_literal: true

version = File.read('VERSION').strip

Gem::Specification.new do |s|
  s.name        = 'paramore'
  s.version     = version
  s.summary     = "A declarative approach to Rails' strong parameter formatting and sanitizing"
  s.description = <<~DESC
    Paramore lets you declare which parameters are permitted and what object is responsible
    for formatting/sanitizing/type-casting them before they passed along to your models/processors.
    It is intended to reduce the amount of imperative code in controllers.
  DESC

  s.license = 'MIT'

  s.author   = 'Lukas Kairevičius'
  s.email    = 'lukas.kairevicius9@gmail.com'
  s.homepage = 'https://github.com/lumzdas/paramore'

  s.files         = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.executables   = ['paramore']
  s.require_path  = 'lib'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'bundler', '~> 2.0'

  s.add_runtime_dependency 'rails', '~> 5.0'

  s.post_install_message = <<~MSG
    Thank you for installing Paramore #{version} !
    From the command line you can run `paramore` to generate a configuration file

    More details here         : #{s.homepage}/blob/master/README.md
    Feel free to report issues: #{s.homepage}/issues
  MSG
end
