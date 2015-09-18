class RetriesController < ApplicationController
  def create
    sync_summary = find_sync_summary
    RetryJob.perform_later(sync_summary)

    redirect_to sync_summary_retry_path(sync_summary: sync_summary)
  end

  def show
  end

  private

  def find_sync_summary
    SyncSummary.find(params[:sync_summary_id]).tap do |summary|
      unless summary.users.include?(current_user)
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
