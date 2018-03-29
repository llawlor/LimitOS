class AddBroadcastToDeviceIdToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :broadcast_to_device_id, :integer
    add_index :devices, :broadcast_to_device_id
  end
end
