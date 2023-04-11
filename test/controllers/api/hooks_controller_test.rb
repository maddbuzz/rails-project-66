# frozen_string_literal: true

require 'test_helper'

module Api
  class HooksControllerTest < ActionDispatch::IntegrationTest
    setup do
      @repository = repositories(:ruby_app)
      @github_id = @repository.github_id
    end

    test 'should receive push-events and react accordingly' do
      assert_no_enqueued_jobs
      assert_difference('Repository::Check.count', +1) do
        post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'push' }
        assert { @repository.checks.last.started? }
        assert_enqueued_with job: CheckRepositoryJob
        assert_response :ok
      end

      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'push' }
        assert_response :conflict
      end

      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: 1000 } }, headers: { 'X-GitHub-Event': 'push' }
        assert_response :not_found
      end
    end

    test 'should receive ping-events and react accordingly' do
      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'ping' }
        assert_response :ok
      end
      assert_no_enqueued_jobs
    end

    test 'should receive over events and react accordingly' do
      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'pull_request' }
        assert_response :not_implemented
      end
      assert_no_enqueued_jobs
    end
  end
end
