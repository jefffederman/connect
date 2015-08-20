require "rails_helper"

describe NamelyImporter do
  describe "#import" do
    it "creates a Namely profile for each recent hire" do
      namely_connection = namely_connection_double
      recent_hires_with_dupes = double("recent_hires_with_dupes")
      candidate = double(
        "recent_hire",
        name_the_first: "Dade",
        name_the_last: "Murphy",
        email: "crash.override@example.com",
      )
      recent_hires = [candidate]
      duplicate_filter = double("duplicate_filter", filter: recent_hires)
      normalizer = Proc.new do |original|
        {
          first_name: original.name_the_first,
          last_name: original.name_the_last,
          email: original.email,
        }
      end
      importer = described_class.new(
        namely_connection: namely_connection,
        normalizer: normalizer,
        duplicate_filter: duplicate_filter,
      )

      status = importer.import(recent_hires_with_dupes)

      expect(duplicate_filter).to have_received(:filter).with(
        recent_hires_with_dupes,
        namely_connection: namely_connection,
        normalizer: normalizer,
      )
      expect(status).to be_an ImportResult
      expect(status[candidate]).to be_success
    end

    it "flags recent hires with no email address" do
      namely_connection = namely_connection_double
      recent_hires = [{ first_name: "Dade", last_name: "Murphy", email: "" }]
      duplicate_filter = double("duplicate_filter", filter: recent_hires)

      candidate = { first_name: "Dade", last_name: "Murphy", email: "" }
      recent_hires = [candidate]
      importer = described_class.new(
        namely_connection: namely_connection,
        normalizer: -> (original) { original },
        duplicate_filter: duplicate_filter,
      )

      status = importer.import(recent_hires)

      expect(status).to be_an ImportResult
      expect(status[candidate].error).
        to eq t("status.missing_required_field", message: "email")
    end
  end

  describe "#single_import" do
    it "imports a single user" do
      namely_connection = namely_connection_double
      candidate = double(
        "recent_hire",
        name_the_first: "Dade",
        name_the_last: "Murphy",
        email: "crash.override@example.com",
      )
      normalizer = Proc.new do |original|
        {
          first_name: original.name_the_first,
          last_name: original.name_the_last,
          email: original.email,
        }
      end
      importer = described_class.new(
        namely_connection: namely_connection,
        normalizer: normalizer,
      )

      status = importer.single_import(candidate)

      expect(status).to be_success
    end
  end

  def namely_connection_double
    profile = double("Namely::Model")
    profiles = double("Namely::Collection", create!: profile)
    double("Namely::Connection", profiles: profiles)
  end
end
