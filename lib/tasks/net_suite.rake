namespace :net_suite do
  desc "Export Namely profiles to NetSuite for all users"
  task export: :environment do
    BulkSync.sync(:net_suite)
  end
end
