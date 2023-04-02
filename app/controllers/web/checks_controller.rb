# frozen_string_literal: true

TEMP_GIT_CLONES_PATH = 'tmp/git_clones'

module Web
  class ChecksController < ApplicationController
    before_action :authenticate_user!

    def show
      @repository = Repository.find(params[:repository_id])
      authorize @repository

      @check = Repository::Check.find(params[:id])
    end

    def create
      @repository = Repository.find(params[:repository_id])
      authorize @repository

      @repo_check = @repository.checks.new
      # t.string "aasm_state"

      last_commit = HTTParty.get("https://api.github.com/repos/#{@repository.owner_name}/#{@repository.repo_name}/commits").first
      @repo_check.commit_id = last_commit['sha'][...7]

      @repo_check.check_date = Time.current

      run_programm "rm -rf #{TEMP_GIT_CLONES_PATH}"
      temp_repo_path = "#{TEMP_GIT_CLONES_PATH}/#{@repository.repo_name}"
      run_programm "git clone #{@repository.link}.git #{temp_repo_path}"
      run_programm "find #{temp_repo_path} -name '*eslint*.*' -type f -delete"

      # stdout, exit_status = run_programm "yarn run eslint #{temp_repo_path}"
      # pp stdout
      # pp exit_status
      stdout, exit_status = run_programm "yarn run eslint --format json #{temp_repo_path}"

      @repo_check.was_the_check_passed = exit_status.zero?

      json_string = stdout.split("\n")[2]
      eslint_file_results_array = JSON.parse(json_string)

      @repo_check.number_of_violations = 0
      @repo_check.check_results = []

      eslint_file_results_array
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
          @repo_check.number_of_violations += 1
        end
        @repo_check.check_results << src_file
      end
      # pp @repo_check

      @repo_check.save!

      # json_file_path = 'tmp/git_clones/out.json'
      # run_programm "rm -rf #{json_file_path}"
      # file = File.new(json_file_path, 'w')
      # file.write(json_string)
      # file.close
    ensure
      run_programm "rm -rf #{TEMP_GIT_CLONES_PATH}"
    end

    private

    def run_programm(command)
      stdout, exit_status = Open3.popen3(command) do |_stdin, stdout, _stderr, wait_thr|
        [stdout.read, wait_thr.value]
      end
      # pp stdout # вывод stdout
      # pp exit_status.exitstatus # https://docs.ruby-lang.org/en/2.0.0/Process/Status.html#method-i-exitstatus
      [stdout, exit_status.exitstatus]
    end
  end
end
