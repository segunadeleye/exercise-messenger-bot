class CreatePerformedRoutines < ActiveRecord::Migration[5.2]
  def change
    create_table :performed_routines do |t|
      t.references :workout_session, null: false, index: true
      t.references :routine, null: false, index: true
      t.integer :status, index: true

      t.timestamps
    end
  end
end
