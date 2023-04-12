# frozen_string_literal: true

module Stubs
  class OctokitClient
    def initialize(*args); end

    def repos
      github_repos = JSON.load_file File.open(GITHUB_REPOS_JSON_PATH) # array of "github" repos
      github_repos.each(&:deep_symbolize_keys!)
    end

    def repo(github_id)
      # repos.find { |repo| repo[:id] == github_id }
      repos_from_file = repos
      size = repos_from_file.size
      i = (github_id % size)
      repo = repos[i]
      repo[:id] = github_id
      repo
    end

    def create_hook(*args, **kwargs); end
  end
end
