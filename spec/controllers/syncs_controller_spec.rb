require 'rails_helper'

describe SyncsController do
  describe 'POST create' do
    let(:user) { create(:user) }

    before do
      session[:current_user_id] = user.id
    end

    it 'performs a sync job' do
      connection = create(:net_suite_connection,
        :ready,
        installation: user.installation
      )

      expect(SyncJob).to receive(:perform_later).with(connection)

      post :create, integration_id: connection.integration_id
    end
  end
end
