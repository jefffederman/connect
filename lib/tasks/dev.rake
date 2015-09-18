if Rails.env.development?
  namespace :dev do
    desc "Clear all local field mappings for debugging"
    task reset_field_mappings: :environment do
      AttributeMapper.destroy_all
    end
  end
end
