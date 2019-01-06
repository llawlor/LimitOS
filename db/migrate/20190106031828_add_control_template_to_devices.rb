class AddControlTemplateToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :control_template, :string
  end
end
