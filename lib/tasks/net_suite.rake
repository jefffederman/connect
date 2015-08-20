namespace :net_suite do
  desc "Export Namely profiles to NetSuite for all users"
  task export: :environment do
    BulkSync.new(integration_id: :net_suite, users: User.all).sync
  end
end
