# encoding: utf-8
require File.expand_path('../lib/osaka/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'osaka'
  gem.version = Osaka::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "Osaka is an Mac GUI automation library"
  gem.description = "Osaka wraps osascript (Applescript) and provides a ruby interface for automating tasks through the GUI on Mac"

  gem.authors  = ['Bas Vodde']
  gem.email    = 'basv@odd-e.com'
  gem.homepage = 'https://github.com/basvodde/osaka'

  gem.add_dependency('rake')
  gem.add_development_dependency('rspec', [">= 2.0.0"])

  gem.files = `git ls-files -- {.,test,spec,lib}/*`.split("\n")
end
