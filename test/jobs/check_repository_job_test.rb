# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  test 'perform javascript-repo check' do
    completed_check = repository_checks(:javascript_app_completed_check)
    check = completed_check.repository.checks.new
    check.save!

    assert { check.started? }

    CheckRepositoryJob.perform_now check

    assert { check.completed? }

    assert { check.passed == completed_check.passed }
    assert { check.number_of_violations == completed_check.number_of_violations }
    assert { check.check_results == completed_check.check_results }
  end

  test 'perform ruby-repo check' do
    completed_check = repository_checks(:ruby_app_completed_check)
    check = completed_check.repository.checks.new
    check.save!

    assert { check.started? }

    CheckRepositoryJob.perform_now check

    assert { check.completed? }

    assert { check.passed == completed_check.passed }
    assert { check.number_of_violations == completed_check.number_of_violations }
    assert { check.check_results == completed_check.check_results }
  end
end
