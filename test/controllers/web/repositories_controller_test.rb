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
      get new_repository_url
      assert_response :success
    end

    test 'should create (add) selected repository' do
      github_id = 1
      assert { !Repository.exists?(github_id:) }

      post repositories_path, params: { repository: { github_id: '' } }
      assert_redirected_to new_repository_path
      assert_flash 'web.repositories.create.repository_has_not_been_added', :alert

      post repositories_path, params: { repository: { github_id: } }

      assert_enqueued_with job: RepositoryUpdateJob
      assert_enqueued_with job: CreateRepositoryWebhookJob

      assert_redirected_to repositories_path
      assert_flash 'web.repositories.create.repository_has_been_added'

      last_repository = Repository.last
      assert { last_repository.github_id == github_id }
      assert { last_repository.user == current_user }
    end

    test 'should show repository' do
      repository = current_user.repositories.last
      assert { repository }
      get repository_url(repository)
      assert_response :success
    end
  end
end
