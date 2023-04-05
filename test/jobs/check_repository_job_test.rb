# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  test 'perform check' do
    hexlet_ci_app_check = repository_checks(:hexlet_ci_app_check)
    check = repository_checks(:started_check)

    assert { check.started? }

    CheckRepositoryJob.perform_now check.repository, check

    check.reload
    assert { check.completed? }

    assert { check.was_the_check_passed == hexlet_ci_app_check.was_the_check_passed }
    assert { check.number_of_violations == hexlet_ci_app_check.number_of_violations }
    assert { check.check_results == hexlet_ci_app_check.check_results }
  end
end
