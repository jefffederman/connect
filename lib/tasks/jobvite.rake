namespace :jobvite do
  desc "Import new Jobvite candidates for all users"
  task :import => :environment do
    BulkSync.new(integration_id: :jobvite, users: User.all).sync
  end
end
