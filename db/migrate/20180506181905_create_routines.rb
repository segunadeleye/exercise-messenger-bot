class CreateRoutines < ActiveRecord::Migration[5.2]
  def change
    create_table :routines do |t|
      t.references :workout
      t.references :exercise
      t.integer :set
      t.integer :repetition
      t.integer :preparation
      t.integer :start
      t.integer :hold
      t.integer :release
      t.integer :pause
      t.integer :position

      t.timestamps
    end
  end
end
