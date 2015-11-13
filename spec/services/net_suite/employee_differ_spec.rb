require 'rails_helper'

describe NetSuite::EmployeeDiffer do
  describe '#different?' do
    let(:attribute_mapper) { create(:attribute_mapper) }
    let(:namely_employee) do
      NetSuite::Normalizer.new(
        attribute_mapper: attribute_mapper,
        configuration: double(subsidiary_id: 123)
      ).export(namely)
    end

    before do
      create(:field_mapping,
        attribute_mapper: attribute_mapper,
        integration_field_id: "firstName",
        namely_field_name: "first_name")
      create(:field_mapping,
        attribute_mapper: attribute_mapper,
        integration_field_id: "gender",
        namely_field_name: "gender")
    end

    subject(:differ) do
      described_class.new(namely_employee: namely_employee, netsuite_employee: netsuite)
    end

    context 'when the Namely Profile has changed' do
      let(:namely) { build(:namely_profile, first_name: "Bobby") }
      let(:netsuite) { build(:netsuite_profile, first_name: "Bob") }


      it 'returns true' do
        expect(differ).to be_different
      end
    end

    context 'when the Namely Profile has case differences' do
      let(:namely) { build(:namely_profile, first_name: "Bob") }
      let(:netsuite) { build(:netsuite_profile, first_name: "BOB") }

      it 'returns false' do
        expect(differ).to_not be_different
      end
    end

    context 'when the Namely Profile has space as padding differences' do
      let(:namely) { build(:namely_profile, first_name: "Bob ") }
      let(:netsuite) { build(:netsuite_profile, first_name: " Bob") }

      it 'returns false' do
        expect(differ).to_not be_different
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
