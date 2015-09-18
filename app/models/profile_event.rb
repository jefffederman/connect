class ProfileEvent < ActiveRecord::Base
  belongs_to :sync_summary

  # Intended to be called via the association from a SyncSummary which will
  # provide the required `sync_summary_id` attribute.
  def self.create_from_result!(result)
    create!(
      profile_id: result.profile_id,
      profile_name: result.name,
      error: result.error
    )
  end

  def self.ordered
    order(profile_name: :asc)
  end

  def self.successful
    where(error: nil)
  end

  def self.failed
    where.not(error: nil)
  end

  def successful?
    error.nil?
  end
end
