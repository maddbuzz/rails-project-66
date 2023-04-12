# frozen_string_literal: true

class DowncaseLanguage < ActiveRecord::Migration[7.0]
  def change
    Repository.find_each do |repository|
      language = repository.language.downcase
      repository.update(language:)
    end
  end
end
