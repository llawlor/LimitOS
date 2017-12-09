class CreateSynchronizations < ActiveRecord::Migration[5.0]
  def change
    create_table :synchronizations do |t|
      t.string :name
      t.integer :device_id
      t.text :message

      t.timestamps
    end
    add_index :synchronizations, :device_id
  end
end
