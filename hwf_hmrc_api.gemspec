# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "hwf_hmrc_api"
  spec.version       = "0.2.9"
  spec.authors       = ["Petr Zaparka"]
  spec.email         = ["petr@zaparka.cz"]

  spec.summary       = "Link between HwF and HMRC API."
  spec.description   = "Basic logic to communicate and parse data to/from HMRC API."
  spec.homepage      = "https://github.com/hmcts/hwf_hmrc_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.1")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ministryofjustice/glimr-api-client"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "httparty", "~> 0.22.0"
  spec.add_dependency "rotp", "~> 6.3.0"
  spec.add_dependency "uuid", "~> 2.3.9"
  spec.add_development_dependency "base64"
  spec.add_development_dependency "vcr"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
