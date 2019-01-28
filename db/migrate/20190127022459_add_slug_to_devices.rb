class AddSlugToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :slug, :string
    add_index :devices, :slug
  end
end
