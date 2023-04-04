# frozen_string_literal: true

require 'test_helper'

class CheckRepositoryJobTest < ActiveJob::TestCase
  # test 'perform check' do
  #   check = checks(:started)

  #   # uri_template = Addressable::Template.new 'https://api.github.com/repos/{owner_name}/{repo_name}'
  #   # response = load_fixture('files/response.json')
  #   # stub_request(:get, uri_template)
  #   #   .to_return(
  #   #     status: 200,
  #   #     body: response,
  #   #     headers: { 'Content-Type' => 'application/json' }
  #   #   )
  #   # old_description = repo.description

  #   CheckRepositoryJobTest.perform_now repo.id
  #   repo.reload

  #   assert { repo.fetched? }
  #   assert { old_description != repo.description }
  # end
end
