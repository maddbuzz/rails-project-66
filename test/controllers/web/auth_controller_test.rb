# frozen_string_literal: true

module Web
  class AuthControllerTest < ActionDispatch::IntegrationTest
    test 'check request' do
      post auth_request_path('github')
      assert_response :redirect
    end

    test 'check callback and logout' do
      mock_omni_auth(users(:one))

      get callback_auth_path('github')
      assert_response :redirect
      assert_flash 'web.auth.callback.signed_in'
      assert signed_in?

      delete auth_logout_path
      assert_response :redirect
      assert_flash 'web.auth.logout.signed_out'
      assert_not signed_in?
    end
  end
end
