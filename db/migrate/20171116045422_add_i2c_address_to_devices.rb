class AddI2cAddressToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :i2c_address, :string, limit: 10
  end
end
