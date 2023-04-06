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

    # # # # control_class = Elements.const_get(as.capitalize)
    language_class = repository.language.to_s.downcase.upcase_first.constantize

    check.check!
    lint_check = ApplicationContainer[:lint_check]
    json_string = lint_check.call(temp_repo_path, language_class)
    check.mark_as_checked!

    check.parse!
    check.check_results, number_of_violations = parse_check(temp_repo_path, language_class, json_string)
    check.number_of_violations = number_of_violations
    check.was_the_check_passed = number_of_violations.zero?
    check.mark_as_parsed!

    check.save!
    check.mark_as_completed!
  rescue StandardError => e
    check.mark_as_failed!
    Rails.logger.debug e
    Rollbar.error e
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

def lint_check(temp_repo_path, language_class)
  language_class.linter(temp_repo_path) # json_string
end

def parse_check(temp_repo_path, language_class, json_string)
  language_class.parser(temp_repo_path, json_string) # [check_results, number_of_violations]
end

def run_programm(command)
  stdout, exit_status = Open3.popen3(command) do |_stdin, stdout, _stderr, wait_thr|
    [stdout.read, wait_thr.value]
  end
  # pp stdout # вывод stdout
  # pp exit_status.exitstatus # https://docs.ruby-lang.org/en/2.0.0/Process/Status.html#method-i-exitstatus
  [stdout, exit_status.exitstatus]
end
