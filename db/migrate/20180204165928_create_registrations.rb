class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.string :auth_token, limit: 6
      t.integer :device_id
      t.datetime :expires_at

      t.timestamps
    end
    add_index :registrations, :auth_token
    add_index :registrations, :device_id
  end
end
