class AddVideoInvertVerticalToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :video_invert_vertical, :boolean, default: false
  end
end
