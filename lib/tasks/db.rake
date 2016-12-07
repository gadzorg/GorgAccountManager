namespace :db do
  desc "TODO"
  task create_external_test_db: :environment do
    if Rails.env.test?
      ActiveRecord::Tasks::DatabaseTasks.create :soce_test


    else
      puts "You tried to use create_external_test_db in #{Rails.env} environment"
      puts "You could break soce and platal rec/prod environments"
      puts "Use this instead :"
      puts "RAILS_ENV=test bundle exec rake db:create_external_test_db"
    end
  end

end
