# frozen_string_literal: true

require 'test_helper'

module Web
  module Repositories
    class ChecksControllerTest < ActionDispatch::IntegrationTest
      setup do
        sign_in users(:user1)
      end

      test 'should get show' do
        check = repository_checks(:javascript_bad_check)
        get repository_check_path(check.repository.id, check.id)
        assert_response :success
      end

      test 'should create a new check' do
        repository = repositories(:repository3)

        post repository_checks_path(repository)
        assert_redirected_to repository
        assert_flash 'web.repositories.checks.create.check_created'

        last_check = Repository::Check.last
        assert { last_check.finished? }
        assert { last_check.passed }
        assert { last_check.number_of_violations.zero? }
        assert { last_check.check_results.empty? }
      end
    end
  end
end
