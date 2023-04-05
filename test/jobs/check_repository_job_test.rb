# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  test 'perform check' do
    bad_check = repository_checks(:bad_check)
    check = repository_checks(:started_check)

    assert { check.started? }

    check_repository_job = ApplicationContainer[:check_repository_job]
    assert { check_repository_job == CheckRepositoryJobStub }
    check_repository_job.perform_now check.repository, check

    assert { check.completed? }

    assert { check.was_the_check_passed == bad_check.was_the_check_passed }
    assert { check.number_of_violations == bad_check.number_of_violations }
    assert { check.check_results == bad_check.check_results }
  end
end
