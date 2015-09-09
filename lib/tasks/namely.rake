namespace :namely do
  desc "Refresh access tokens for all users"
  task refresh_access_tokens: :environment do
    User.all.each do |user|
      TokenRefreshJob.perform_later(user)
    end
  end
end
