class SyncSummary < ActiveRecord::Base
  belongs_to :connection, polymorphic: true
  has_many :profile_events, dependent: :destroy
  has_many(
    :successful_profile_events,
    -> { successful.ordered },
    class_name: "ProfileEvent"
  )
  has_many(
    :failed_profile_events,
    -> { failed.ordered },
    class_name: "ProfileEvent"
  )

  delegate :installation, :integration_id, to: :connection
  delegate :users, to: :installation
  delegate :namely_profiles, to: :installation

  def self.create_from_results!(results:, connection:)
    transaction do
      create!(connection: connection).tap do |sync_summary|
        sync_summary.convert_results_to_profile_events(results)
      end
    end
  end

  def self.ordered
    order(created_at: :desc)
  end

  def convert_results_to_profile_events(results)
    results.each do |result|
      profile_events.create_from_result!(result)
    end
  end

  def failed_profiles
    failed_ids = failed_profile_events.pluck(:profile_id)

    namely_profiles.select do |profile|
      failed_ids.include?(profile.id)
    end
  end

  def retry
    connection.retry(self)
  end
end
