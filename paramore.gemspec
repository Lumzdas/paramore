version = File.read('VERSION').strip

Gem::Specification.new do |spec|
  spec.name        = 'paramore'
  spec.version     = version
  spec.summary     = "A declarative approach to Rails' strong parameter typing and sanitizing"
  spec.description = <<~DESC
    Paramore lets you declare which parameters are permitted and what object is responsible
    for typing/sanitizing/type-casting them before they are passed along to your models/domain.
    It is intended to reduce the amount of imperative code in controllers.
  DESC

  spec.license = 'MIT'

  spec.author   = 'Lukas Kairevičius'
  spec.email    = 'lukas.kairevicius9@gmail.com'
  spec.homepage = 'https://github.com/lumzdas/paramore'

  spec.files         = `git ls-files bin lib *.md LICENSE`.split("\n")
  spec.executables   = ['paramore']
  spec.require_path  = 'lib'

  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'combustion', '~> 1.3'
  spec.add_development_dependency 'pry'#, '~> 1.3'

  spec.add_runtime_dependency 'rails', '>= 5.0'

  spec.post_install_message = <<~MSG
    Thank you for installing Paramore #{version} !
    From the command line you can run `paramore` to generate a configuration file

    More details here         : #{spec.homepage}/blob/master/README.md
    Feel free to report issues: #{spec.homepage}/issues
  MSG
end
