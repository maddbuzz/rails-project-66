# frozen_string_literal: true

module API
  class HooksController < API::ApplicationController
    # before_action :set_repository, only: %i[show]

    def github_webhook
      # @repository = ?
      # last_check = @repository.checks.last
      # return unless !last_check || last_check.completed? || last_check.failed?

      # @check = @repository.checks.new
      # @check.save!

      # CheckRepositoryJob.perform_later @repository, @check
      # flash[:notice] = t('.webhook_check_started', repo: @repository.repo_name) if @repository.user == current_user
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

    #   private

    #   def set_repository
    #     @repository = ::Repository.find(params[:id])
    #     authorize @repository
    #   end

    #   def repository_params
    #     params.require(:repository).permit(:github_repo_id)
    #   end
  end
end
