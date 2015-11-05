require 'rails_helper'

describe NetSuite::EmployeeDiffer do
  describe '#different?' do
    let(:attribute_mapper) { create(:attribute_mapper) }

    before do
      create(:field_mapping,
        attribute_mapper: attribute_mapper,
        integration_field_id: "firstName",
        namely_field_name: "first_name")
    end

    subject(:differ) do
      described_class.new(mapper: attribute_mapper, namely_profile: namely, netsuite_employee: netsuite)
    end

    context 'when the Namely Profile has changed' do
      let(:namely) { build(:namely_profile, first_name: "Bobby") }
      let(:netsuite) { build(:netsuite_profile, first_name: "Bob") }

      it 'returns true' do
        expect(differ).to be_different
      end
    end

    context 'when the Namely Profile has not changed' do
      let(:namely) { build(:namely_profile) }
      let(:netsuite) { build(:netsuite_profile) }

      it 'returns false' do
        expect(differ).to_not be_different
      end
    end
  end
end
