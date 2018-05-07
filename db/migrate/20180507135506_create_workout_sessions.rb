class CreateWorkoutSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :workout_sessions do |t|
      t.references :user, null: false, index: true
      t.references :workout, null: false, index: true
      t.integer :status, null: false, index: true, default: 0

      t.timestamps
    end
  end
end
