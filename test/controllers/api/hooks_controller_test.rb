# frozen_string_literal: true

require 'test_helper'

module Api
  class HooksControllerTest < ActionDispatch::IntegrationTest
    setup do
      @repository = repositories(:ruby_app)
      @github_id = @repository.github_id
    end

    test 'should receive push-events and react accordingly' do
      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: 1000 } }, headers: { 'X-GitHub-Event': 'push' }
        assert_response :not_found
      end
      assert_enqueued_jobs 0

      post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'push' }
      assert_response :ok
      last_check = @repository.checks.last
      assert { last_check.created? }
      assert_enqueued_jobs 1
      assert_enqueued_with job: CheckRepositoryJob

      assert_no_difference('Repository::Check.count') do
        post api_checks_url, params: { repository: { id: @github_id } }, headers: { 'X-GitHub-Event': 'push' }
        assert_response :conflict
      end
      assert_enqueued_jobs 1

      perform_enqueued_jobs # performs all of the enqueued jobs up to this point in the test
      last_check.reload
      assert { last_check.finished? }

      ruby_bad_check = repository_checks(:ruby_bad_check)
      assert { last_check.passed == ruby_bad_check.passed }
      assert { last_check.number_of_violations == ruby_bad_check.number_of_violations }
      assert { last_check.check_results == ruby_bad_check.check_results }
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
