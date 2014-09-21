Gem::Specification.new do |spec|
  spec.name          = "mova"
  spec.version       = "0.1.0"
  spec.authors       = ["Andrii Malyshko"]
  spec.email         = ["mail@nashbridges.me"]
  spec.summary       = "Translation and localization library"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mova-rb/mova"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
