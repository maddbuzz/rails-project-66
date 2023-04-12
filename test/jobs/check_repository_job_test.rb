# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  test 'perform javascript-repo check' do
    finished_check = repository_checks(:javascript_app_finished_check)
    check = finished_check.repository.checks.new
    check.save!

    assert { check.created? }

    CheckRepositoryJob.perform_now check

    assert { check.finished? }

    assert { check.passed == finished_check.passed }
    assert { check.number_of_violations == finished_check.number_of_violations }
    assert { check.check_results == finished_check.check_results }
  end

  test 'perform ruby-repo check' do
    finished_check = repository_checks(:ruby_app_finished_check)
    check = finished_check.repository.checks.new
    check.save!

    assert { check.created? }

    CheckRepositoryJob.perform_now check

    assert { check.finished? }

    assert { check.passed == finished_check.passed }
    assert { check.number_of_violations == finished_check.number_of_violations }
    assert { check.check_results == finished_check.check_results }
  end
end
