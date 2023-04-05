# frozen_string_literal: true

TEMP_GIT_CLONES_PATH = 'tmp/git_clones'

class CheckRepositoryJobStub < ApplicationJob
  queue_as :default

  def perform(_repository, check)
    check.check_date = Time.current

    # temp_repo_path = "#{TEMP_GIT_CLONES_PATH}/#{repository.repo_name}"
    temp_repo_path = 'test/fixtures/files/git_clones/hexlet-ci-app/'

    check.fetch!
    check.commit_id = '5702e5b'
    # fetch(repository, check, temp_repo_path) - repo already "fetched"
    check.mark_as_fetched!

    check.check!
    lint_results = linter_check(check, temp_repo_path)
    check.mark_as_checked!

    check.parse!
    parse(check, temp_repo_path, lint_results)
    check.mark_as_parsed!

    check.save!
    check.mark_as_completed!
  rescue StandardError
    check.mark_as_failed!
  end

  private

  def linter_check(check, temp_repo_path)
    run_programm "find #{temp_repo_path} -name '*eslint*.*' -type f -delete"
    stdout, exit_status = run_programm "yarn run eslint --format json #{temp_repo_path}"
    check.was_the_check_passed = exit_status.zero?
    stdout
  end

  def parse(check, temp_repo_path, lint_results)
    json_string = lint_results.split("\n")[2]
    eslint_files_results = JSON.parse(json_string) # array

    check.number_of_violations = 0
    check.check_results = []

    eslint_files_results
      .filter { |file_result| !file_result['messages'].empty? }
      .each do |file_result|
      src_file = {}
      src_file['filePath'] = file_result['filePath'].partition(temp_repo_path).last
      src_file['messages'] = []
      file_result['messages'].each do |message|
        violation = {}
        violation['message'] = message['message']
        violation['ruleId'] = message['ruleId']
        violation['line'] = message['line']
        violation['column'] = message['column']
        src_file['messages'] << violation
        check.number_of_violations += 1
      end
      check.check_results << src_file
    end
  end

  def run_programm(command)
    stdout, exit_status = Open3.popen3(command) do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    # pp stdout # вывод stdout
    # pp exit_status.exitstatus # https://docs.ruby-lang.org/en/2.0.0/Process/Status.html#method-i-exitstatus
    [stdout, exit_status.exitstatus]
  end
end
