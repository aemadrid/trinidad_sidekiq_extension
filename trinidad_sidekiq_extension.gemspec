# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trinidad_sidekiq_extension/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adrian Madrid"]
  gem.email         = ["aemadrid@gmail.com"]
  gem.description   = %q{Runs Sidekiq workers within the Trinidad application server}
  gem.summary       = %q{Runs Sidekiq workers within the Trinidad application server}
  gem.homepage      = "https://github.com/aemadrid/trinidad_sidekiq_extension"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "trinidad_sidekiq_extension"
  gem.require_paths = ["lib"]
  gem.version       = TrinidadThreadedSidekiqExtension::VERSION

  gem.add_development_dependency "rake"
  gem.add_runtime_dependency "trinidad"
  gem.add_runtime_dependency "sidekiq"
end
