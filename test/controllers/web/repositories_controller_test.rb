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
      github_id = 10
      assert { !Repository.exists?(github_id:) }

      post repositories_path, params: { repository: { github_id: '' } }
      assert_redirected_to new_repository_path
      assert_flash 'web.repositories.create.repository_has_not_been_added', :alert

      post repositories_path, params: { repository: { github_id: } }
      last_repository = Repository.last
      assert { last_repository.user == current_user }
      assert { last_repository.github_id == github_id }

      assert_enqueued_with job: RepositoryUpdateJob
      assert_enqueued_with job: CreateRepositoryWebhookJob

      assert_redirected_to repositories_path
      assert_flash 'web.repositories.create.repository_has_been_added'

      perform_enqueued_jobs(only: RepositoryUpdateJob)

      octokit_client = ApplicationContainer[:octokit_client]
      client = octokit_client.new access_token: current_user.token, auto_paginate: true
      github_repo = client.repo(github_id)
      github_repo.deep_symbolize_keys!
      last_repository.reload
      assert { last_repository.link == github_repo[:html_url] }
      assert { last_repository.owner_name == github_repo[:owner][:login] } # need deep_symbolize_keys!, not just symbolize_keys!
      assert { last_repository.name == github_repo[:name] }
      assert { last_repository.language == github_repo[:language].downcase }
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
