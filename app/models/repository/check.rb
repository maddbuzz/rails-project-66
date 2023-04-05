# frozen_string_literal: true

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
      state :parsing
      state :parsed
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

      event :parse do
        transitions from: :checked, to: :parsing
      end

      event :mark_as_parsed do
        transitions from: :parsing, to: :parsed
      end

      event :mark_as_completed do
        transitions from: :parsed, to: :completed
      end

      event :mark_as_failed do
        transitions to: :failed
      end
    end
  end
end
