class AddAuthTokenToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :auth_token, :string, limit: 24
    add_index :devices, :auth_token, unique: true
  end
end
