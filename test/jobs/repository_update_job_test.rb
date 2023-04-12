# frozen_string_literal: true

require 'test_helper'

class RepositoryUpdateJobTest < ActiveJob::TestCase
  test 'update job' do
    github_id = 9
    assert { !Repository.exists?(github_id:) }
    user = users(:user1)
    repository = user.repositories.new(github_id:)

    RepositoryUpdateJob.perform_now repository, user.token

    octokit_client = ApplicationContainer[:octokit_client]
    client = octokit_client.new access_token: user.token, auto_paginate: true
    github_repo = client.repo(github_id)

    github_repo.deep_symbolize_keys!
    assert { repository.link == github_repo[:html_url] }
    assert { repository.owner_name == github_repo[:owner][:login] } # need deep_symbolize_keys!, not just symbolize_keys!
    assert { repository.name == github_repo[:name] }
    assert { repository.language == github_repo[:language] }
    assert { repository.repo_created_at == github_repo[:created_at] }
    assert { repository.repo_updated_at == github_repo[:updated_at] }
  end
end
