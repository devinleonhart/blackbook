# frozen_string_literal: true

# Service to generate descriptive filenames for images
class DescriptiveFilenameService
  def self.generate_for_image(image)
    new(image).generate
  end

  def initialize(image)
    @image = image
  end

  def generate
    return nil unless @image&.image_file&.attached?

    parts = []

    # Universe name (sanitized)
    if @image.universe&.name.present?
      parts << sanitize_for_filename(@image.universe.name)
    else
      parts << "unknown_universe"
    end

    # Character names (sorted for consistency)
    character_names = @image.characters.pluck(:name).compact.sort
    if character_names.any?
      sanitized_characters = character_names.map { |name| sanitize_for_filename(name) }
      parts.concat(sanitized_characters)
    else
      parts << "no_characters"
    end

    # Original UUID from blob key (to maintain uniqueness)
    blob_key = @image.image_file.blob.key
    parts << blob_key

    # Extension
    extension = @image.image_file.blob.filename.extension_without_delimiter

    filename = parts.join('_')
    filename += ".#{extension}" if extension.present?

    filename
  end

  # Generate filename for a new image (before characters are tagged)
  def self.generate_for_new_image(universe, original_filename, blob_key)
    parts = []

    # Universe name
    if universe&.name.present?
      parts << sanitize_for_filename(universe.name)
    else
      parts << "unknown_universe"
    end

    # No characters yet for new images
    parts << "untagged"

    # UUID
    parts << blob_key

    # Extension
    extension = File.extname(original_filename).delete('.')

    filename = parts.join('_')
    filename += ".#{extension}" if extension.present?

    filename
  end

  # Update filename when characters are added/removed
  def self.update_filename_for_image(image)
    return nil unless image&.image_file&.attached?

    old_filename = image.local_filename
    new_filename = generate_for_image(image)

    return old_filename if old_filename == new_filename

    # If we have a local file with the old name, rename it
    if old_filename && Rails.env.production?
      old_path = local_file_path_for_filename(old_filename)
      new_path = local_file_path_for_filename(new_filename)

      if File.exist?(old_path) && old_path != new_path
        begin
          FileUtils.mkdir_p(File.dirname(new_path))
          FileUtils.mv(old_path, new_path)
          Rails.logger.info("Renamed local file from #{old_filename} to #{new_filename}")
        rescue => e
          Rails.logger.error("Failed to rename local file: #{e.message}")
        end
      end
    end

    new_filename
  end

  def self.local_file_path_for_filename(filename)
    return nil unless filename

    # Create a simple hash-based directory structure for organization
    hash = Digest::MD5.hexdigest(filename)
    Rails.root.join("storage", "descriptive", hash[0..1], hash[2..3], filename)
  end

  private_class_method :local_file_path_for_filename

  private

  def sanitize_for_filename(text)
    self.class.sanitize_for_filename(text)
  end

  def self.sanitize_for_filename(text)
    return "empty" if text.blank?

    # Convert to ASCII, remove special characters, limit length
    text.to_s
        .unicode_normalize(:nfd)
        .gsub(/[^\x00-\x7F]/, '') # Remove non-ASCII
        .gsub(/[^a-zA-Z0-9\-_]/, '_') # Replace special chars with underscore
        .gsub(/_+/, '_') # Collapse multiple underscores
        .gsub(/^_|_$/, '') # Remove leading/trailing underscores
        .downcase
        .slice(0, 30) # Limit length
        .presence || "unnamed"
  end
end
