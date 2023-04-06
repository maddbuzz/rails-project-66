# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

GITHUB_REPOS_JSON_PATH = 'test/fixtures/files/github_repos.json'
ESLINTER_JSON_PATH = 'test/fixtures/files/eslinter.json'
RUBOCOP_JSON_PATH = 'test/fixtures/files/rubocop.json'
STUBS_MAP = { 'Javascript' => ESLINTER_JSON_PATH, 'Ruby' => RUBOCOP_JSON_PATH }.freeze

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end
    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

def t(*args, **kwargs)
  I18n.t(*args, **kwargs)
end

def assert_flash(i18n_path, type = :notice)
  assert_equal t(i18n_path), flash[type]
end

# Теперь OmniAuth в тестах не обращается к внешним источникам
OmniAuth.config.test_mode = true

def mock_omni_auth(user, provider = :github)
  auth_hash = {
    provider: provider.to_s,
    uid: '12345',
    info: {
      email: user.email,
      nickname: user.nickname
    },
    credentials: {
      token: user.token
    }
  }
  OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash::InfoHash.new(auth_hash)
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user, _options = {})
      mock_omni_auth(user)
      get callback_auth_url('github')
    end

    def signed_in?
      session[:user_id].present? && current_user.present?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end

class OctokitClientStub
  def initialize(*args); end

  def repos
    github_repos = JSON.load_file File.open(GITHUB_REPOS_JSON_PATH) # array of "github" repos
    github_repos.each(&:deep_symbolize_keys!)
  end

  def repo(github_repo_id)
    repos.find { |repo| repo[:id] == github_repo_id }
  end
end

def fetch_repo_data_stub(_repository, _temp_repo_path)
  '5702e5b' # commit_id
end

def lint_check_stub(_temp_repo_path, language_class)
  File.read(STUBS_MAP[language_class.to_s]) # json_string
end
