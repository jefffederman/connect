class AddProfileIdToProfileEvents < ActiveRecord::Migration
  def up
    add_column :profile_events, :profile_id, :string
    change_column_null :profile_events, :profile_id, false, ""
  end

  def down
    remove_column :profile_events, :profile_id
  end
end
