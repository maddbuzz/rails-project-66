# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :user, class_name: 'User', inverse_of: :repositories

  validates :github_repo_id, uniqueness: true, presence: true, numericality: { only_integer: true }

  extend Enumerize
  enumerize :language, in: [:JavaScript]
end
