class AddTimeZoneToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :time_zone, :string, limit: 50
  end
end
