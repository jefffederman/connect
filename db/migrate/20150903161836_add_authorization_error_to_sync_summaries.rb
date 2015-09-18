class AddAuthorizationErrorToSyncSummaries < ActiveRecord::Migration
  def change
    add_column(:sync_summaries, :authorization_error, :string)
  end
end
