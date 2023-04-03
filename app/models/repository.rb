# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :repositories
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy

  scope :by_owner, ->(owner_user) { where(user_id: owner_user.id) }

  validates :github_repo_id, uniqueness: true, presence: true, numericality: { only_integer: true }

  extend Enumerize
  enumerize :language, in: [:JavaScript]
end

class Repository
  class Check < ApplicationRecord
    belongs_to :repository, class_name: 'Repository', inverse_of: :checks

    include AASM

    aasm do
      state :started, initial: true
      state :fetching
      state :fetched
      state :checking
      state :checked
      state :completed
      state :failed

      event :fetch do
        transitions from: :started, to: :fetching
      end

      event :mark_as_fetched do
        transitions from: :fetching, to: :fetched
      end

      event :check do
        transitions from: :fetched, to: :checking
      end

      event :mark_as_checked do
        transitions from: :checking, to: :checked
      end

      event :mark_as_completed do
        transitions from: :checked, to: :completed
      end

      event :mark_as_failed do
        transitions to: :failed
      end
    end
  end
end
