class AddValueToSynchronizedPins < ActiveRecord::Migration[5.1]
  def change
    add_column :synchronized_pins, :value, :string
  end
end
