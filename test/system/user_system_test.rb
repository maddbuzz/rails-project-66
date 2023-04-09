# frozen_string_literal: true

require 'application_system_test_case'

class UserSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:user1)
    sign_in @user
  end

  test 'should be on the root' do
    assert_text t('web.home.index.Hello from Hexlet!')
    assert_text t('web.home.index.Repository Quality Analyzer')
  end

  test 'should add repository' do
    owner_name = @user.nickname
    repo_name = 'repo_name1'
    full_name = "#{owner_name}/#{repo_name}"

    click_on t('layouts.shared.nav.repositories')
    click_on t('web.repositories.index.new')
    assert_text t('web.repositories.new.title')

    assert_difference('Repository.count', +1) do
      select full_name, from: 'repository[github_repo_id]'
      click_on t('web.repositories.new.submit')
      assert_text t('web.repositories.create.Repository has been added')
    end

    last_repository = Repository.last
    assert { owner_name == last_repository.owner_name }
    assert { repo_name == last_repository.repo_name }
    assert { "https://github.com/#{full_name}" == last_repository.link }
  end
end
