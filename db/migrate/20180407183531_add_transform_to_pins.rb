class AddTransformToPins < ActiveRecord::Migration[5.1]
  def change
    add_column :pins, :transform, :string
  end
end
