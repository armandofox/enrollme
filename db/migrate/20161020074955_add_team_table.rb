class AddTeamTable < ActiveRecord::Migration
  def change
    create_table :teams do |e|
      e.boolean :approved
      e.string :passcode
      e.integer :submission_id
      e.timestamps null: false
    end
  end
end
