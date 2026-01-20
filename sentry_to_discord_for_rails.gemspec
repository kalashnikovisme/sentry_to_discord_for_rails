# frozen_string_literal: true

require_relative "lib/sentry_to_discord_for_rails/version"

Gem::Specification.new do |spec|
  spec.name = "sentry_to_discord_for_rails"
  spec.version = SentryToDiscordForRails::VERSION
  spec.authors = ["Pavel Kalashnikov"]
  spec.email = ["kalashnikovisme@gmail.com"]

  spec.summary = "Rails Engine to forward Sentry webhooks to Discord."
  spec.description = "A Rails Engine that receives Sentry webhooks and forwards them to a configured Discord webhook " \
                     "with rich formatting."
  spec.homepage = "https://github.com/kalashnikovisme/sentry_to_discord_for_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "rails", ">= 6.0"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "webmock"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
