class RenameVideoInvertField < ActiveRecord::Migration[5.1]
  def change
    rename_column :devices, :video_invert_vertical, :invert_video
  end
end
