# frozen_string_literal: true

require 'test_helper'

module Web
  module Repositories
    class ChecksControllerTest < ActionDispatch::IntegrationTest
      setup do
        sign_in users(:user1)
      end

      test 'should get show' do
        check = repository_checks(:javascript_app_finished_check)
        get repository_check_path(check.repository.id, check.id)
        assert_response :success
      end

      test 'should create a new check and prevent another one from being created until the first one has finished' do
        repository = repositories(:repository3)

        post repository_checks_path(repository)
        assert_redirected_to repository
        assert_flash 'web.repositories.checks.create.Check created'

        # .perform_later jobs are not actually run in tests, but we can check for their queuing:
        assert_enqueued_with job: CheckRepositoryJob

        post repository_checks_path(repository)
        assert_redirected_to repository
        assert_flash 'web.repositories.checks.create.Wait for the previous check to complete', :alert
      end
    end
  end
end