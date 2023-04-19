# frozen_string_literal: true

require 'application_system_test_case'

class UserSystemTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper # for .perform_enqueued_jobs

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

    assert { !Repository.exists?(full_name:) }

    click_on t('layouts.shared.nav.repositories')
    click_on t('web.repositories.index.new')
    assert_text t('web.repositories.new.title')

    select full_name, from: 'repository[github_id]'
    click_on t('web.repositories.new.submit')
    assert_text t('web.repositories.create.repository_has_been_added')

    perform_enqueued_jobs(only: RepositoryUpdateJob) # include ActiveJob::TestHelper for this method

    assert { Repository.exists?(full_name:) }
  end
end
