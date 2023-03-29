# frozen_string_literal: true

class User < ApplicationRecord
  has_many :repositories, dependent: :destroy, inverse_of: :user

  validates :email, presence: true
  validates :token, presence: true
end
