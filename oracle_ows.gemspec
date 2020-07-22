require_relative 'lib/oracle_ows/version'

Gem::Specification.new do |spec|
  # required attributes
  #
  spec.name          = 'oracle_ows'
  spec.version       = OracleOWS::VERSION
  spec.summary       = 'Oracle OWS'
  spec.files         = Dir.glob('lib/**/*') # load everything in lib folder tree
  # # Specify which files should be added to the gem when it is released.
  # # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path(__dir__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end

  # recommended attributes
  #
  spec.authors       = ['Ram']
  spec.email         = ['RamOnRails@gmail.com']
  spec.description   = 'Oracle Hospitality OPERA Web Self-Service'
  spec.homepage      = 'https://github.com/ramonrails/oracle_ows'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ramonrails/oracle_ows'
  spec.metadata['changelog_uri']   = 'https://github.com/ramonrails/oracle_ows/CHANGELOG.md'

  # additional attributes
  #
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'savon', '~> 2.12'
  #
  # check Gemfile
  #
  # spec.add_development_dependency 'guard', '~> 2.16'
  # spec.add_development_dependency 'rspec', '~> 3.9'

  # optional attributes
  #
  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # spec.bindir        = 'exe'
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
end
