# frozen_string_literal: true

module Api
  class HooksController < Api::ApplicationController
    skip_before_action :verify_authenticity_token

    def github_webhook
      case request.headers['X-GitHub-Event']
      when 'ping'
        accept_ping
      # TODO: when 'push', nil # for hexlet check only!
      when 'push'
        accept_push repository_params[:id]
      else
        render json: { '501': 'Not implemented' }, status: :not_implemented
      end
    end

    private

    def accept_push(github_repo_id)
      repository = ::Repository.find_by(github_repo_id:)
      return render json: { '404': 'Not found' }, status: :not_found unless repository

      last_check = repository.checks.last
      return render json: { '409': 'Conflict' }, status: :conflict unless !last_check || last_check.completed? || last_check.failed?

      check = repository.checks.new
      check.save!

      CheckRepositoryJob.perform_later repository, check
      render json: { '200': 'Ok' }, status: :ok
    end

    def accept_ping
      render json: { '200': 'Ok', application: Rails.application.class.module_parent_name }, status: :ok
    end

    def repository_params
      params.require('repository').permit('id')
    end
  end
end
