class CreateSynchronizedPins < ActiveRecord::Migration[5.1]
  def change
    create_table :synchronized_pins do |t|
      t.integer :pin_id
      t.integer :synchronization_id
      t.integer :device_id

      t.timestamps
    end
    add_index :synchronized_pins, :pin_id
    add_index :synchronized_pins, :synchronization_id
    add_index :synchronized_pins, :device_id
  end
end
