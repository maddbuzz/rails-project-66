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
  end
end

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :octokit_client, -> { OctokitClientStub }
    register :fetch_repo_data, ->(repository, temp_repo_path) { fetch_repo_data_stub(repository, temp_repo_path) }
    register :linter_check, ->(temp_repo_path) { linter_check_stub(temp_repo_path) }
  else
    register :octokit_client, -> { Octokit::Client }
    register :fetch_repo_data, ->(repository, temp_repo_path) { fetch_repo_data(repository, temp_repo_path) }
    register :linter_check, ->(temp_repo_path) { linter_check(temp_repo_path) }
  end
end

# # Получение зависимостей из контейнера:
# octokit_client = ApplicationContainer[:octokit_client]
# client = octokit_client.new access_token: current_user.token, auto_paginate: true
# # Вызов зависимости с параметрами:
# fetch_repo_data = ApplicationContainer[:fetch_repo_data]
# check.commit_id = fetch_repo_data.call(repository, temp_repo_path)
