require "rails_helper"

describe RetriesController do
  describe "#create" do
    it "prevents users from retrying summaries they don't own" do
      session[:current_user_id] = create(:user).id
      summary = create(:sync_summary)
      summary.installation.users << create(
        :user,
        installation: summary.installation
      )

      expect { post :create, sync_summary_id: summary.id }.
        to raise_error ActiveRecord::RecordNotFound
    end
  end
end
