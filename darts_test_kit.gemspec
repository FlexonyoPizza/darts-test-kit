require_relative 'lib/darts_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'darts_test_kit'
  spec.version       = DartsTestKit::VERSION
  spec.authors       = ['leon11']
  # spec.email         = ['TODO']
  spec.summary       = 'Darts Test Kit'
  # spec.description   = <<~DESCRIPTION
  #   This is a big markdown description of the test kit.
  # DESCRIPTION
  # spec.homepage      = 'TODO'
  spec.license       = 'Apache-2.0'
  spec.add_dependency 'inferno_core', '~> 1.2.2'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['inferno_test_kit'] = 'true'
  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO'
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets execution_scripts LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
