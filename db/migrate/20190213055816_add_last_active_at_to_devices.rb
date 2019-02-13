class AddLastActiveAtToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :last_active_at, :datetime
  end
end
