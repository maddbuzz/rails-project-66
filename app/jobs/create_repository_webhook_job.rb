# frozen_string_literal: true

class CreateRepositoryWebhookJob < ApplicationJob
  queue_as :default

  def perform(repository)
    user_token = repository.user.token
    octokit_client = ApplicationContainer[:octokit_client]
    client = octokit_client.new access_token: user_token, auto_paginate: true

    hooks_array = client.hooks(repository.github_repo_id)
    Rails.logger.debug { "hooks_array = #{hooks_array}\n" }

    # url = 'https://webhook.site/2da4e6ff-56e3-4938-b322-10b8384f5fb4'
    url = Rails.application.routes.url_helpers.api_checks_url
    hook_info = client.create_hook(
      repository.github_repo_id, # "#{repository.owner_name}/#{repository.repo_name}",
      'web',
      {
        url:,
        content_type: 'json',
        insecure_ssl: Rails.env.production? ? '0' : '1'
      },
      {
        events: %w[push],
        active: true
      }
    )
    # if already exists, nothing to worry: Octokit::UnprocessableEntity, 422 - Validation Failed,
    #   Error summary:
    #     resource: Hook
    #     code: custom
    #     message: Hook already exists on this repository

    Rails.logger.debug { "hook_info = #{hook_info}\n" }
  end
end
