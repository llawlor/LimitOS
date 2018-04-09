class AddOutputPinToPins < ActiveRecord::Migration[5.1]
  def change
    add_column :pins, :output_pin_number, :integer
  end
end
