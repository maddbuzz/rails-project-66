# frozen_string_literal: true

require 'test_helper'

module Api
  class HooksControllerTest < ActionDispatch::IntegrationTest
    test 'should receive webhook and act accordingly' do
      github_repo_id = repositories(:ruby_app).github_repo_id
      post api_checks_url, params: { repository: { id: github_repo_id } }, headers: { 'X-GitHub-Event': 'push' }
      assert_enqueued_with job: CheckRepositoryJob
      assert_response :success
    end
  end
end
