require "rails_helper"

describe NetsuiteImportsController do
  describe "#create" do
    it "creates a new netsuite import" do
      session[:current_user_id] = create(:user).id
      netsuite_import = double("NetsuiteImport")
      allow(Netsuite::Import).to receive(:new).and_return(netsuite_import)
      allow(netsuite_import).to receive(:import)

      post :create

      expect(Netsuite::Import).to have_received(:new)
      expect(netsuite_import).to have_received(:import)
      expect(response).to be_success
    end
  end
end
