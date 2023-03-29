# frozen_string_literal: true

require 'test_helper'

module Web
  class RepositoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @repository = repositories(:one)
      sign_in users(:one)
    end

    test 'should get index' do
      get repositories_url
      assert_response :success
    end

    # test 'should get new' do
    #   get new_repository_url
    #   assert_response :success
    # end

    # test 'should create repository' do
    #   assert_difference('Repository.count') do
    #     post repositories_url, params: { repository: { github_repo_id: 3, language: :JavaScript } }
    #   end
    #   assert_redirected_to repository_url(Repository.last)
    # end

    # test 'should show repository' do
    #   get repository_url(@repository)
    #   assert_response :success
    # end
  end
end
