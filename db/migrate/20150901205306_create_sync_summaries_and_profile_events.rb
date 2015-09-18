class CreateSyncSummariesAndProfileEvents < ActiveRecord::Migration
  def change
    create_table :sync_summaries do |t|
      t.references :connection, polymorphic: true, null: false, index: true
      t.timestamps null: false
    end

    create_table :profile_events do |t|
      t.references :sync_summary, null: false, index: true
      t.string :profile_name, null: false
      t.timestamps null: false
    end
  end
end
