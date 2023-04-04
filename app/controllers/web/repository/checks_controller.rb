# frozen_string_literal: true

module Web
  module Repository
    class ChecksController < Web::Repository::ApplicationController
      before_action :authenticate_user!
      before_action :set_repository, only: %i[show create]

      def show
        @check = Check.find(params[:id])
        authorize @check
      end

      def create
        last_check = @repository.checks.last
        unless !last_check || last_check.completed? || last_check.failed?
          redirect_to @repository, alert: t('.Wait for the previous check to complete')
          return
        end

        @check = @repository.checks.new
        authorize @check
        @check.save!

        CheckRepositoryJob.perform_later @repository, @check
        redirect_to @repository, notice: t('.Check started')
      end

      private

      def set_repository
        @repository = ::Repository.find(params[:repository_id])
        authorize @repository
      end
    end
  end
end
