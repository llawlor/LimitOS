class AddVideoEnabledToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :video_enabled, :boolean, default: false
  end
end
