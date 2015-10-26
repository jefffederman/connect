module Features
  def stub_namely_fields(fixture_file)
    stub_namely_data("/profiles/fields", fixture_file)
  end

  def stub_namely_data(path, fixture_file)
    fixture = namely_fixture(fixture_file)
    parsed = JSON.load(fixture)
    resource_name = parsed.keys.first

    stub_request(:get, %r{.*api/v1#{Regexp.escape(path)}}).
      to_return(status: 200, body: fixture)

    stub_request(:get, %r{.*api/v1#{Regexp.escape(path)}.*(after=.*)}).
      to_return(status: 200, body: { resource_name => [] }.to_json)
  end

  def namely_fixture(fixture_file)
    File.read("spec/fixtures/api_responses/#{fixture_file}.json")
  end
end
