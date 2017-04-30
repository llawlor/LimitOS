class CreatePins < ActiveRecord::Migration[5.0]
  def change
    create_table :pins do |t|
      t.references :device, foreign_key: true
      t.string :name
      t.string :pin_type
      t.integer :pin_number
      t.integer :min
      t.integer :max

      t.timestamps
    end

    add_index :pins, [:device_id, :pin_number]
  end
end
