class ActivityFeedsController < IntegrationController
  def show
    @sync_summaries = connection.
      sync_summaries.
      includes(:successful_profile_events, :failed_profile_events).
      ordered.
      page(params[:page]).
      per(10)
  end
end
