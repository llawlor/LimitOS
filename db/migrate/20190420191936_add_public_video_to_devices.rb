class AddPublicVideoToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :public_video, :boolean, default: false
  end
end
