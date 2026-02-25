require_relative 'lib/obs/version'

Gem::Specification.new do |spec|
  spec.name          = "huaweicloud-obs"  # Noté que cambiaste el nombre
  spec.version       = OBS::VERSION
  spec.authors       = ["Miguel Angel Timana Paz"]
  spec.email         = ["migueltimanapaz@gmail.com"]

  spec.summary       = "Cliente Ruby para OBS (Object Storage Service)"
  spec.description   = "Una gema para interactuar con servicios de almacenamiento de objetos compatible con S3"
  spec.homepage      = "https://github.com/huawei-delivery-peru/huaweicloud-sdk-ruby-obs"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Especifica qué archivos deben incluirse en la gema
  spec.files = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency 'httparty', '>= 0.18'
end