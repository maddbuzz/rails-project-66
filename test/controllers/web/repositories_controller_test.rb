# frozen_string_literal: true

require 'test_helper'

# GITHUB_API_PATH = 'https://api.github.com/'
REPOS_JSON_FILE_NAME = 'github_repos.json'

module Web
  class RepositoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in users(:user1)
    end

    test 'should get index' do
      get repositories_url
      assert_response :success
    end

    test 'should get new (select from the list)' do
      # stub_request(:get, "#{GITHUB_API_PATH}user/repos")
      #   .to_return(body: file_fixture(REPOS_JSON_FILE_NAME), status: 200, headers: { content_type: 'application/json' })

      get new_repository_url
      assert_response :success
    end

    test 'should create (add) selected repository' do
      github_repo_id = 1
      assert { !Repository.exists?(github_repo_id:) }
      repository_last_id = Repository.last.id

      github_repos = JSON.load_file file_fixture(REPOS_JSON_FILE_NAME) # array of "github" repos
      github_repo = github_repos.find { |repo| repo['id'] == github_repo_id }
      # stub_request(:get, "#{GITHUB_API_PATH}repositories/#{github_repo_id}")
      #   .to_return(body: github_repo.to_json, status: 200, headers: { content_type: 'application/json' })

      post repositories_path, params: { repository: { github_repo_id: '' } }
      assert_redirected_to new_repository_path
      assert_flash 'web.repositories.create.Repository has not been added', :alert

      post repositories_path, params: { repository: { github_repo_id: } }
      assert_redirected_to repositories_path
      assert_flash 'web.repositories.create.Repository has been added'

      last_repository = Repository.last
      assert { last_repository.github_repo_id == github_repo_id }
      assert { last_repository.id > repository_last_id }
      assert { last_repository.user == current_user }

      github_repo.deep_symbolize_keys!
      assert { last_repository.link == github_repo[:html_url] }
      assert { last_repository.owner_name == github_repo[:owner][:login] } # need deep_symbolize_keys!, not just symbolize_keys!
      assert { last_repository.repo_name == github_repo[:name] }
      assert { last_repository.language == github_repo[:language] }
      assert { last_repository.repo_created_at == github_repo[:created_at] }
      assert { last_repository.repo_updated_at == github_repo[:updated_at] }
    end

    test 'should show repository' do
      repository = current_user.repositories.last
      assert { repository }
      get repository_url(repository)
      assert_response :success
    end
  end
end
