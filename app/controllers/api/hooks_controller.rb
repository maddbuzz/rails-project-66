# frozen_string_literal: true

module Api
  class HooksController < Api::ApplicationController
    # before_action :set_repository, only: %i[show]

    def github_webhook
      debugger
      # @repository = ?
      # last_check = @repository.checks.last
      # return unless !last_check || last_check.completed? || last_check.failed?

      # @check = @repository.checks.new
      # @check.save!

      # CheckRepositoryJob.perform_later @repository, @check
      # flash[:notice] = t('.webhook_check_started', repo: @repository.repo_name) if @repository.user == current_user
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
