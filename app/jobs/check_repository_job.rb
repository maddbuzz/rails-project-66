# frozen_string_literal: true

TEMP_GIT_CLONES_PATH = 'tmp/git_clones'

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(repository, check)
    check.check_date = Time.current

    temp_repo_path = "#{TEMP_GIT_CLONES_PATH}/#{repository.repo_name}/"

    check.fetch!
    fetch_repo_data = ApplicationContainer[:fetch_repo_data]
    check.commit_id = fetch_repo_data.call(repository, temp_repo_path)
    check.mark_as_fetched!

    check.check!
    linter_check = ApplicationContainer[:linter_check]
    json_string, check.was_the_check_passed = linter_check.call(temp_repo_path)
    check.mark_as_checked!

    check.parse!
    check.check_results, check.number_of_violations = parse(temp_repo_path, json_string)
    check.mark_as_parsed!

    check.save!
    check.mark_as_completed!
  rescue StandardError
    check.mark_as_failed!
  ensure
    run_programm "rm -rf #{temp_repo_path}"
  end
end

def fetch_repo_data(repository, temp_repo_path)
  run_programm "rm -rf #{temp_repo_path}"

  _, exit_status = run_programm "git clone #{repository.link}.git #{temp_repo_path}"
  raise StandardError unless exit_status.zero?

  last_commit = HTTParty.get("https://api.github.com/repos/#{repository.owner_name}/#{repository.repo_name}/commits").first
  last_commit['sha'][...7]
end

def linter_check(temp_repo_path)
  run_programm "find #{temp_repo_path} -name '*eslint*.*' -type f -delete"
  stdout, exit_status = run_programm "yarn run eslint --format json #{temp_repo_path}"
  json_string = stdout.split("\n")[2]
  [json_string, exit_status.zero?]
end

def parse(temp_repo_path, json_string)
  eslint_files_results = JSON.parse(json_string) # array

  number_of_violations = 0
  check_results = []

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
      number_of_violations += 1
    end
    check_results << src_file
  end
  [check_results, number_of_violations]
end

def run_programm(command)
  stdout, exit_status = Open3.popen3(command) do |_stdin, stdout, _stderr, wait_thr|
    [stdout.read, wait_thr.value]
  end
  # pp stdout # вывод stdout
  # pp exit_status.exitstatus # https://docs.ruby-lang.org/en/2.0.0/Process/Status.html#method-i-exitstatus
  [stdout, exit_status.exitstatus]
end
