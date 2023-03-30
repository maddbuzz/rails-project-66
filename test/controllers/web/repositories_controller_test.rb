# frozen_string_literal: true

require 'test_helper'

GITHUB_API_PATH = 'https://api.github.com/'
REPOS_JSON_FILENAME = 'github_repos.json'

module Web
  class RepositoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:one)
    end

    test 'should get index' do
      get repositories_url
      assert_response :success
    end

    test 'should get new (select from the list)' do
      stub_request(:get, "#{GITHUB_API_PATH}user/repos")
        .to_return(body: file_fixture(REPOS_JSON_FILENAME), status: 200, headers: { content_type: 'application/json' })

      get new_repository_url
      assert_response :success
    end

    test 'should create (add) repository' do
      github_repos = JSON.load_file file_fixture(REPOS_JSON_FILENAME) # array of "github" repos
      github_repo_id = 1
      github_repo = github_repos.find { |repo| repo['id'] == github_repo_id }

      stub_request(:get, "#{GITHUB_API_PATH}repositories/#{github_repo_id}")
        .to_return(body: github_repo.to_json, status: 200, headers: { content_type: 'application/json' })

      post repositories_url, params: { repository: { github_repo_id: } }
      assert_redirected_to repositories_url

      github_repo.deep_symbolize_keys!
      assert do
        current_user.repositories.exists?(
          github_repo_id: github_repo[:id],
          link: github_repo[:html_url],
          owner_name: github_repo[:owner][:login], # need deep_symbolize_keys!, not just symbolize_keys!
          repo_name: github_repo[:name],
          language: github_repo[:language],
          repo_created_at: github_repo[:created_at],
          repo_updated_at: github_repo[:updated_at]
        )
      end
    end

    test 'should show repository' do
      repository = current_user.repositories.last
      assert { repository }
      get repository_url(repository)
      assert_response :success
    end
  end
end
