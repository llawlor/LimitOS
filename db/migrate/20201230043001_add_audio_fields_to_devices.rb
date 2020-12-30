class AddAudioFieldsToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :audio_enabled, :boolean, default: false
    add_column :devices, :audio_start_pin, :integer
  end
end
