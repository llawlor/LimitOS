class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :name
      t.integer :device_id
      t.string :device_type

      t.timestamps
    end
    add_index :devices, :user_id
    add_index :devices, :device_id
  end
end
