# frozen_string_literal: true

namespace :db do
  desc "Reset and seed development database"
  task dev_reset: :environment do
    puts "🔄 Resetting development database..."
    system("docker compose exec blackbook bundle exec rails db:reset")
    puts "✅ Development database reset and seeded successfully!"
    puts "🔐 Admin login: admin@blackbook.dev / password123"
  end

  desc "Reset and seed test database"
  task test_reset: :environment do
    puts "🔄 Resetting test database..."
    system("docker compose exec blackbook bundle exec rails db:reset RAILS_ENV=test")
    puts "✅ Test database reset and seeded successfully!"
    puts "🔐 Admin login: admin@blackbook.dev / password123"
  end

  desc "Seed both development and test databases"
  task seed_all: :environment do
    puts "🌱 Seeding development database..."
    Rake::Task["db:seed"].invoke

    puts "🌱 Seeding test database..."
    system("RAILS_ENV=test rails db:seed")

    puts "✅ Both databases seeded successfully!"
    puts "🔐 Admin login: admin@blackbook.dev / password123"
  end

  desc "Show database statistics"
  task stats: :environment do
    puts "📊 Database Statistics:"
    puts "  👥 Users: #{User.count}"
    puts "  🌌 Universes: #{Universe.count}"
    puts "  👤 Characters: #{Character.count}"
    puts "  🖼️  Images: #{Image.count}"
    puts "  🏷️  Image tags: #{ImageTag.count}"
    puts "  🏷️  Character tags: #{CharacterTag.count}"
    puts "  🤝 Collaborations: #{Collaboration.count}"
  end
end
