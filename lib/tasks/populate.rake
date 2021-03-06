# lib/tasks/populate.rake
#
# Rake task to populate development database with test data
# Run it with "rake db:populate"
# See Railscast 126 and the faker website for more information

namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    puts "Environement = #{Rails.env}"
    require 'faker'

    Rake::Task['db:reset'].invoke

    def generate_hruid
      FactoryBot.attributes_for(:user).fetch(:hruid)
    end

    # Create admin_user account
    admin_user = User.create!(:email => "admin@poubs.org",
                              :firstname => Faker::Name.first_name,
                              :lastname => Faker::Name.last_name,
                              :password => "password",
                              :password_confirmation => "password",
                              :role => Role.find_by_name(:admin),
                              :hruid => generate_hruid,
                              )


    puts "Admin mail = #{admin_user.email}"
    puts "Admin name = #{admin_user.fullname}"

    # Create support_user account
    support_user = User.create!(:email => "support@poubs.org",
                              :firstname => Faker::Name.first_name,
                              :lastname => Faker::Name.last_name,
                              :password => "password",
                              :password_confirmation => "password",
                              :role => Role.find_by_name(:support),
                              :hruid => generate_hruid,
    )


    puts "Support mail = #{support_user.email}"
    puts "Support name = #{support_user.fullname}"

    # Create basic users account

    basic_users = (1..3).map do |i|
        User.create!( :email => "user#{i}@poubs.org",
                      :firstname => Faker::Name.first_name,
                      :lastname => Faker::Name.last_name,
                      :password => "password",
                      :password_confirmation => "password",
                      :role => nil,
                      :hruid => generate_hruid,
        )
      end

    basic_users.each do |u|
      puts "User mail = #{u.email}"
      puts "User name = #{u.fullname}"
    end



  end
end
