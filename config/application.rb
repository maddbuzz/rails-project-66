# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsProject66
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.exceptions_app = routes # this line for custom error pages

    routes
      .default_url_options =
      if Rails.env.test?
        { host: 'http://127.0.0.1:3000' }
      else
        { host: ENV.fetch('BASE_URL', nil) } # необходимо, чтобы сформировать внешнюю ссылку на наш сервис...
      end
  end
end

# autoload :Stubs, './test/test_helper' if Rails.env.test?

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    autoload :Stubs, './test/test_helper'
    register :octokit_client, -> { Stubs::OctokitClientStub }
    register :fetch_repo_data, ->(repository, temp_repo_path) { Stubs.fetch_repo_data_stub(repository, temp_repo_path) }
    register :lint_check, ->(temp_repo_path, language_class) { Stubs.lint_check_stub(temp_repo_path, language_class) }
  else
    register :octokit_client, -> { Octokit::Client }
    register :fetch_repo_data, ->(repository, temp_repo_path) { fetch_repo_data(repository, temp_repo_path) }
    register :lint_check, ->(temp_repo_path, language_class) { lint_check(temp_repo_path, language_class) }
  end
end
