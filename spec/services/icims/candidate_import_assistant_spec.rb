require "rails_helper"

describe Icims::CandidateImportAssistant do
  describe "#candidate" do
    it "returns a candidate from contextual params" do
      candidate = candidate_double
      context = candidate_importer_double
      import_assistant = Icims::CandidateImportAssistant.new(context: context)
      allow_any_instance_of(Icims::Client).to receive(:candidate).
        and_return(candidate)

      expect(import_assistant.candidate).to eq(candidate)
    end
  end

  describe "#attribute_mapper" do
    it "returns an attribute mapper object" do
      context = candidate_importer_double
      import_assistant = Icims::CandidateImportAssistant.new(context: context)

      expect(import_assistant.attribute_mapper).to be_instance_of(
        Icims::AttributeMapper
      )
    end
  end

  def candidate_importer_double
    double(
      CandidateImporter,
      connection: double(:connection),
      params: {}
    )
  end

  def candidate_double
    double(:candidate, id: -1)
  end
end
