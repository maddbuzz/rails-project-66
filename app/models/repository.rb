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
      state :created, initial: true
      state :fetching
      state :fetched
      state :failed
      state :checking
      state :checked

      event :fetch do
        transitions from: %i[created fetched failed checked], to: :fetching
      end

      event :rollback do # ???
        transitions from: :fetching, to: :created
      end

      event :mark_as_fetched do
        transitions from: :fetching, to: :fetched
      end

      event :mark_as_checked do
        transitions from: :checking, to: :checked
      end

      event :mark_as_failed do
        transitions to: :failed
      end
    end
  end
end
