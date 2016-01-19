require 'spec_helper'

describe Users::AccessTokenFreshener do
  describe '.fresh_access_token' do
    let(:user) do
      double :user,
        access_token_expiry: expires,
        access_token: 'token',
        subdomain: 'https://example.com', 
        refresh_token: 'refresh_token'
    end
    let(:authenticator) { double :authenticator }
    let(:authenticator_class) do 
      double :authenticator_class,
        new: authenticator
    end

    before do
      stub_const("Authenticator", authenticator_class)
    end

    context 'when expire access token' do
      let(:expires) { 1.day.ago }
      let(:tokens) do 
        { 'access_token' => 'refreshed_token', 
          'expires_in' => 'refreshed_expires' }
      end

      it 'refresh access token' do
        expect(authenticator).to receive(:refresh_access_token).
          with('refresh_token') { tokens }

        expect(user).to receive(:save_token_info).
          with(tokens['access_token'], tokens['expires_in'])

        described_class.fresh_access_token(user)
      end
    end

    context 'when access token has not expire' do
      let(:expires) { Time.now }

      it 'does not refresh access token' do
        Timecop.freeze Time.now do 
          expect(authenticator).to_not receive(:refresh_access_token)
          expect(user).to_not receive(:save_token_info)

          described_class.fresh_access_token(user)
        end
      end
    end
  end
end
