class RenameMessageToMessagesOnSynchronizations < ActiveRecord::Migration[5.0]
  def change
    rename_column :synchronizations, :message, :messages
  end
end
