# frozen_string_literal: true

module Web
  class RepositoriesController < Web::ApplicationController
    before_action :authenticate_user!, only: %i[index show new create]
    before_action :set_repository, only: %i[show]

    def index
      authorize ::Repository
      @repositories = ::Repository.by_owner(current_user)
    end

    def show
      @checks = @repository.checks.order(created_at: :desc)
    end

    def new
      @repository = ::Repository.new
      authorize @repository

      languages = ::Repository.language.values
      @select_options = user_repos_list
                        .filter { |repo| languages.include?(repo[:language]) }
                        .map { |repo| [repo[:full_name], repo[:id]] }
    end

    def create
      @repository = current_user.repositories.find_or_initialize_by(repository_params)
      authorize @repository

      if repository_update
        CreateRepositoryWebhookJob.perform_later(@repository)
        redirect_to repositories_url, notice: t('.Repository has been added')
      else
        # render :new, status: :unprocessable_entity
        redirect_to new_repository_path, alert: t('.Repository has not been added')
      end
    end

    private

    def user_repos_list
      octokit_client = ApplicationContainer[:octokit_client]
      client = octokit_client.new access_token: current_user.token, auto_paginate: true
      client.repos # получение списка репозиториев
    end

    def repository_update
      return false if @repository.github_id.nil?

      octokit_client = ApplicationContainer[:octokit_client]
      client = octokit_client.new access_token: current_user.token, auto_paginate: true
      github_repo = client.repo(@repository.github_id)
      return false if github_repo.nil?

      @repository.update(
        link: github_repo[:html_url],
        owner_name: github_repo[:owner][:login],
        name: github_repo[:name],
        full_name: github_repo[:full_name],
        language: github_repo[:language],
        repo_created_at: github_repo[:created_at],
        repo_updated_at: github_repo[:updated_at]
      )
    end

    def set_repository
      @repository = ::Repository.find(params[:id])
      authorize @repository
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
