class AddErrorToProfileEvents < ActiveRecord::Migration
  def up
    add_column :profile_events, :error, :string
    add_index :profile_events, :error, where: "error IS NULL"
    update(<<-SQL)
      UPDATE profile_events SET error = 'Unknown Error' WHERE successful = false
    SQL
    remove_column :profile_events, :successful
  end

  def down
    add_column :profile_events, :successful, :boolean
    update(<<-SQL)
      UPDATE profile_events SET successful = error IS NULL
    SQL
    change_column_null :profile_events, :successful, false
    remove_column :profile_events, :error
  end
end
