# frozen_string_literal: true

module SelectOptionHelper
  def generate_collaborator_names(users, existing_collaborators, owner)
    names = []
    users.each do |user|
      next if existing_collaborators.any? do |collaborator|
        collaborator.id == user.id
      end

      next if user.id == owner.id

      names.push([user.display_name, user.id])
    end
    names.sort_by { |pair| pair[0] }
  end
end
