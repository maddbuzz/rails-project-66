# frozen_string_literal: true

class CreateChecks < ActiveRecord::Migration[7.0]
  def change
    create_table :checks do |t|
      t.string :aasm_state
      t.datetime :check_date, precision: nil
      t.boolean :was_the_check_passed, default: false
      t.integer :number_of_violations
      t.string :commit_id
      t.json :check_results

      t.references :repository, null: false, foreign_key: { to_table: :repositories }

      t.timestamps
    end
  end
end
