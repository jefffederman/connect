require "rails_helper"

describe NetsuiteImportsController do
  describe "#create" do
    it "creates a new netsuite import" do
      session[:current_user_id] = create(:user).id
      allow(Netsuite::Import).to receive(:new)

      post :create

      expect(Netsuite::Import).to have_received(:new)
      expect(response).to be_success
    end
  end
end
