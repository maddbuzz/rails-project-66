# frozen_string_literal: true

module Stubs
  autoload :OctokitClient, './lib/stubs/octokit_client'

  def self.fetch_repo_data(_repository, _temp_repo_path)
    '5702e5b' # commit_id
  end

  def self.lint_check(_temp_repo_path, language_class)
    language = language_class.to_s.split('::').last
    File.read(LINTERS_RESULT_MAP[language]) # json_string
  end
end
