# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  test 'perform check' do
    completed_check = repository_checks(:hexlet_ci_app_completed_check)
    check = repository_checks(:hexlet_ci_app_started_check)

    assert { check.started? }

    CheckRepositoryJob.perform_now check.repository, check

    check.reload
    assert { check.completed? }

    assert { check.was_the_check_passed == completed_check.was_the_check_passed }
    assert { check.number_of_violations == completed_check.number_of_violations }
    assert { check.check_results == completed_check.check_results }
  end
end
