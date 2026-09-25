# lib/tasks/db_check.rake
namespace :db do
  desc 'Check database connection'
  task check_connection: :environment do
    begin
      ActiveRecord::Base.connection
      puts 'Connection to the database established successfully.'
    rescue ActiveRecord::NoDatabaseError => e
      puts 'Database does not exist.'
    rescue ActiveRecord::ConnectionNotEstablished => e
      puts 'Connection to the database could not be established.'
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
