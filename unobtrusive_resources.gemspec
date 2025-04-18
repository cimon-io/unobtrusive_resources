lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unobtrusive_resources/version'

Gem::Specification.new do |spec|
  spec.name          = 'unobtrusive_resources'
  spec.version       = UnobtrusiveResources::VERSION
  spec.authors       = ['Alexey Osipenko', 'Serhii Konev']
  spec.email         = ['alexey@cimon.io', 'sergey@cimon.io']

  spec.summary       = 'Controller concern for skinny, concise and declarative actions'
  spec.description   = 'This gem provides number of utility methods to cleanup codebase, related to controllers. Extremely usefull for common resource management actions (CRUD).'
  spec.homepage      = 'https://github.com/cimon-io/unobtrusive_resources'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 3.0', '< 9.0'

  spec.add_development_dependency 'bundler', '~> 2.2.33'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'rspec', '~> 3.7'
end
