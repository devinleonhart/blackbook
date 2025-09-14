# Descriptive Filenames for Images

This feature enhances the image migration system by creating human-readable, descriptive filenames for local storage while maintaining the original cloud storage structure.

## Filename Format

Images are saved locally with the format:
```
<universe>_<character1>_<character2>_..._<uuid>.<extension>
```

### Examples

- `star_wars_luke_skywalker_leia_organa_abc123def456.jpg`
- `marvel_universe_spider_man_iron_man_def789ghi012.png`
- `fantasy_realm_no_characters_jkl345mno678.gif`
- `sci_fi_world_untagged_pqr901stu234.jpg`

## Filename Sanitization

To ensure filesystem compatibility, names are sanitized:

- **Converted to lowercase**
- **Special characters** become underscores (`_`)
- **Multiple underscores** are collapsed to single
- **Non-ASCII characters** are removed
- **Names are limited** to 30 characters each
- **Empty names** become "unnamed"

### Sanitization Examples

| Original | Sanitized |
|----------|-----------|
| `Star Wars` | `star_wars` |
| `Luke Skywalker` | `luke_skywalker` |
| `Spider-Man!` | `spider_man` |
| `Jean-Luc Picard` | `jean_luc_picard` |
| `🚀 Space Adventure` | `space_adventure` |

## Directory Structure

Local files are organized in a hash-based directory structure:
```
storage/
└── descriptive/
    └── ab/
        └── cd/
            └── star_wars_luke_skywalker_abc123def456.jpg
```

This prevents directory overload while maintaining organization.

## Dynamic Filename Updates

Filenames automatically update when:

1. **Characters are tagged** to an image
2. **Characters are untagged** from an image
3. **Character names change** (if you update character names)
4. **Universe names change** (if you update universe names)

The system will rename the local file to match the new descriptive format.

## Usage Commands

### Preview Filenames
See what filenames will be generated before migration:
```bash
rails images:preview_filenames
```

### Migrate with Descriptive Names
Download all images with descriptive filenames:
```bash
rails images:migrate_to_local
```

### Check Individual Image
In Rails console:
```ruby
image = Image.find(123)
puts image.get_or_generate_local_filename
# => "star_wars_luke_skywalker_abc123def456.jpg"

puts image.local_file_path
# => "/app/storage/descriptive/ab/cd/star_wars_luke_skywalker_abc123def456.jpg"
```

## Special Cases

### Untagged Images
Images without character tags get `untagged` in the filename:
```
universe_name_untagged_uuid.jpg
```

### No Characters in Universe
If a universe has no characters:
```
universe_name_no_characters_uuid.jpg
```

### Missing Universe
If universe data is missing:
```
unknown_universe_character_name_uuid.jpg
```

### Multiple Characters
Characters are sorted alphabetically for consistency:
```
marvel_black_widow_iron_man_spider_man_uuid.jpg
```

## Benefits

1. **Human Readable**: Easily identify image content from filename
2. **Organized**: Group images by universe and characters
3. **Unique**: UUID ensures no filename conflicts
4. **Sortable**: Alphabetical organization for easy browsing
5. **Searchable**: Find images by universe or character name
6. **Compatible**: Works with standard filesystems and tools

## Technical Details

### Filename Generation
- Handled by `DescriptiveFilenameService`
- Cached in memory to avoid regeneration
- Updates triggered by `ImageTag` model callbacks

### File Management
- Original cloud files maintain their blob keys
- Local files use descriptive names
- System can serve from either location
- Automatic cleanup of old filenames when updated

### Performance
- Filename generation is fast (no database queries for basic info)
- Directory structure prevents filesystem bottlenecks
- Lazy loading of filenames (generated when needed)

## Migration Considerations

- **Backwards Compatible**: Original Active Storage structure remains intact
- **Fallback Safe**: If descriptive filename fails, falls back to cloud
- **Incremental**: Can migrate images in batches
- **Resumable**: Restart migration without losing progress
- **Verifiable**: Check migration status and fix issues

This feature makes your local image storage much more manageable while maintaining all the safety and reliability of the hybrid storage system.
