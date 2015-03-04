NetSuite.configure do
  email ENV["TEST_NETSUITE_EMAIL"]
  account ENV["TEST_NETSUITE_ACCOUNT"]
  password ENV["TEST_NETSUITE_PASSWORD"]
end
