class RemoveMessageFromSynchronizations < ActiveRecord::Migration[5.1]
  def change
    remove_column :synchronizations, :messages
  end
end
