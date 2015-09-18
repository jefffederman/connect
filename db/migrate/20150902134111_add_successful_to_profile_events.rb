class AddSuccessfulToProfileEvents < ActiveRecord::Migration
  def change
    add_column :profile_events, :successful, :boolean, null: false
  end
end
