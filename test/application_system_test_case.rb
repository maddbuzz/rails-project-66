# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  WebMock.allow_net_connect! # or system tests won't work

  driven_by :selenium, using: :firefox

  def sign_in(user, _options = {})
    mock_omni_auth(user)
    visit callback_auth_url('github')
  end
end
