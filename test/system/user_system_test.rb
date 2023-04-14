# frozen_string_literal: true

require 'application_system_test_case'

class UserSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:user1)
    sign_in @user
  end

  test 'should be on the root' do
    lines = t('web.home.index.lines_array')
    lines.each { |line| assert_text line }
  end

  test 'should add repository' do
    owner_name = @user.nickname
    name = 'name1'
    full_name = "#{owner_name}/#{name}"

    click_on t('layouts.shared.nav.repositories')
    click_on t('web.repositories.index.new')
    assert_text t('web.repositories.new.title')

    assert_difference('Repository.count', +1) do
      select full_name, from: 'repository[github_id]'
      click_on t('web.repositories.new.submit')
      assert_text t('web.repositories.create.repository_has_been_added')
    end
  end
end
