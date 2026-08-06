# frozen_string_literal: true

namespace :db do
  # Development/test database resets live in bin/reset-db and bin/reset-test-db
  # (documented in the README) — the canonical, more robust entry points.

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
