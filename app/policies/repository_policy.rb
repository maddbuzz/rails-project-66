# frozen_string_literal: true

class RepositoryPolicy < ApplicationPolicy
  def github_webhook?
    true
  end

  def index?
    user
  end

  def show?
    user == record.user
  end

  def create?
    user
  end

  def new?
    create?
  end
end
