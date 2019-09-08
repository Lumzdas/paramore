# frozen_string_literal: true

version = File.read('VERSION').strip

Gem::Specification.new do |s|
  s.name    = 'paramore'
  s.version = version
  s.summary = "A declarative approach to Rails' strong parameter formatting and sanitizing"

  # s.required_ruby_version = '>= 2.5.0'

  s.license = 'MIT'

  s.author   = 'Lukas Kairevičius'
  s.email    = 'lukas.kairevicius9@gmail.com'
  s.homepage = 'https://github.com/lumzdas/paramore'

  s.files         = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.executables   = ['paramore']
  s.require_path  = 'lib'

  s.add_development_dependency 'rspec'
end
