require_relative 'lib/darts_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'darts_test_kit'
  spec.version       = DartsTestKit::VERSION
  spec.authors       = ['Leap Orbit/Acro Systems Inc']
  # spec.email         = ['TODO']
  spec.summary       = 'DARTS Test Kit'
  spec.description   = 'Inferno test kit validating operation payload conformance to the DARTS FHIR IG.'
  # spec.homepage      = 'TODO'
  spec.license       = 'Apache-2.0' 
  spec.add_dependency 'inferno_core', '~> 1.3.1', '>= 1.3.1'

  # TODO: Add DAPL version runtime dependency here and remove the gemfile pin after
  # migrating the DAPL Test Kit to an official ONC repository and releasing
  # a gem for it 
  spec.add_runtime_dependency 'dapl_test_kit'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['inferno_test_kit'] = 'true'
  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO'
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets execution_scripts LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
