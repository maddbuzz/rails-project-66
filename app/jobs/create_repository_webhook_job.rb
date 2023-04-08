# frozen_string_literal: true

class CreateRepositoryWebhookJob < ApplicationJob
  queue_as :default

  def perform(repository)
    user_token = repository.user.token
    octokit_client = ApplicationContainer[:octokit_client]
    client = octokit_client.new access_token: user_token, auto_paginate: true
    # url = Rails.application.routes.url_helpers.github_webhook_url
    url = 'https://webhook.site/2da4e6ff-56e3-4938-b322-10b8384f5fb4'
    hook_info = client.create_hook(
      repository.github_repo_id,
      # "#{repository.owner_name}/#{repository.repo_name}",
      'web',
      {
        url:,
        content_type: 'json',
        insecure_ssl: '0'
      },
      {
        events: %w[push],
        active: true
      }
    )
    Rails.logger.debug hook_info
    # debugger
  end
end
