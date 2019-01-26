class AddPublicToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :public, :boolean, default: false
  end
end
