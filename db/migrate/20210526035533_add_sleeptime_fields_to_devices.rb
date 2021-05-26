class AddSleeptimeFieldsToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :sleeptime_start, :time
    add_column :devices, :sleeptime_end, :time
  end
end
