# frozen_string_literal: true

require 'octokit'

module Web
  class RepositoriesController < ApplicationController
    before_action :set_repository, only: %i[show edit update destroy]

    def index
      @repositories = Repository.all
    end

    def show; end

    def new
      @repository = Repository.new
      # authorize @bulletin

      @select_options = user_repos_list
                        .filter { |repo| Repository.language.values.include?(repo.language) }
                        .map { |repo| [repo.full_name, repo.id] }
    end

    def edit; end

    def create
      @repository = current_user.repositories.new(repository_params)
      # authorize @bulletin

      respond_to do |format|
        if repository_update
          format.html { redirect_to repositories_url, notice: t('.Repository has been added') }
          format.json { render :show, status: :created, location: @repository }
        else
          # format.html { render :new, status: :unprocessable_entity }
          # format.json { render json: @repository.errors, status: :unprocessable_entity }
          format.html { redirect_to new_repository_path, alert: t('.Repository has not been added') }
        end
      end
    end

    def update
      respond_to do |format|
        if @repository.update(repository_params)
          format.html { redirect_to repository_url(@repository), notice: t('.Repository was successfully updated') }
          format.json { render :show, status: :ok, location: @repository }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @repository.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @repository.destroy

      respond_to do |format|
        format.html { redirect_to repositories_url, notice: t('.Repository was successfully destroyed') }
        format.json { head :no_content }
      end
    end

    private

    def user_repos_list
      client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      client.repos # получение списка репозиториев
    end

    def repository_update
      return false if @repository.github_repo_id.nil?

      client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      github_data = client.repo(@repository.github_repo_id)

      @repository.update(
        link: github_data[:html_url],
        owner_name: github_data[:owner][:login],
        repo_name: github_data[:name],
        language: github_data[:language],
        repo_created_at: github_data[:created_at],
        repo_updated_at: github_data[:updated_at]
      )
    end

    def set_repository
      @repository = Repository.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit(:github_repo_id)
    end
  end
end
