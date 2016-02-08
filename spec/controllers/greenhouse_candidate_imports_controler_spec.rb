require 'rails_helper'

RSpec.describe GreenhouseCandidateImportsController, type: :controller do
  describe 'POST #create' do
    context 'when the secret key does not exist' do
      it 'returns a 200' do
        post :create, secret_key: "bunk"

        expect(response.status).to be(200)
      end
    end
  end
end
