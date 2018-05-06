class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :sender_id, null: false, index: true

      t.timestamps
    end
  end
end
