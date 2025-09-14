# frozen_string_literal: true

namespace :db do
  desc "Reset and seed development database"
  task dev_reset: :environment do
    puts "Resetting development database..."
    Rake::Task["db:reset"].invoke
    Rake::Task["db:seed"].invoke
    puts "Development database reset and seeded successfully!"
    puts "Admin login: admin@blackbook.dev / password123"
  end

  desc "Reset and seed test database"
  task test_reset: :environment do
    puts "Resetting test database..."
    system("RAILS_ENV=test rails db:reset")
    system("RAILS_ENV=test rails db:seed")
    puts "Test database reset and seeded successfully!"
    puts "Admin login: admin@blackbook.dev / password123"
  end

  desc "Seed both development and test databases"
  task seed_all: :environment do
    puts "Seeding development database..."
    Rake::Task["db:seed"].invoke

    puts "Seeding test database..."
    system("RAILS_ENV=test rails db:seed")

    puts "Both databases seeded successfully!"
    puts "Admin login: admin@blackbook.dev / password123"
  end
end
