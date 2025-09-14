# Image Storage Migration Guide

This document outlines the comprehensive image storage management solution for resolving production database image issues.

## Overview

The image storage management system provides four main rake tasks to handle the complete migration workflow:

1. **Diagnose** - Analyze current image storage status
2. **Mirror** - Sync images between DigitalOcean and local storage
3. **Cleanup** - Remove orphaned local files
4. **Regenerate Thumbnails** - Rebuild all image thumbnails

## Available Rake Tasks

### 1. Diagnostic Report
```bash
rake images:diagnose
```
**Purpose**: Provides a comprehensive report on the current state of image storage.

**What it checks**:
- Total images in database
- Storage distribution (local only, cloud only, both storages, missing both)
- Local storage details (Active Storage vs descriptive filenames)
- File size mismatches
- Orphaned files in both storage systems
- Provides recommendations for next steps

### 2. Mirror All Images
```bash
rake images:mirror_all
```
**Purpose**: Ensures every image exists in both DigitalOcean and local storage.

**What it does**:
- Downloads cloud-only images to local storage (both Active Storage and descriptive paths)
- Uploads local-only images to cloud storage
- Verifies file integrity after transfers
- Skips images that are already mirrored
- Reports errors for images missing from both storages

### 3. Cleanup Orphaned Files
```bash
rake images:cleanup_orphaned
```
**Purpose**: Removes local files that are not associated with any image models.

**What it cleans**:
- Orphaned Active Storage files (blob keys not in database)
- Orphaned descriptive filename files (filenames not matching any current image)
- Empty directories
- Reports total space freed

### 4. Regenerate Thumbnails
```bash
rake images:regenerate_thumbnails
```
**Purpose**: Regenerates all image thumbnails for the application.

**What it does**:
- Creates thumbnails in multiple sizes (100x100, 300x300, 800x600, 1200x900)
- Skips GIF files (which don't need variants)
- Cleans up orphaned variant records
- Forces generation by accessing each variant

### 5. Complete Migration Workflow
```bash
rake images:complete_migration
```
**Purpose**: Runs all four tasks in sequence for a complete migration.

**Workflow**:
1. Diagnose current state
2. Mirror all images
3. Cleanup orphaned files
4. Regenerate thumbnails
5. Suggests running diagnosis again to verify completion

## Storage Architecture

The application uses a hybrid storage system with two local storage formats:

### Active Storage Format
- Path: `storage/[first2chars]/[next2chars]/[blob_key]`
- Example: `storage/ab/cd/abcd1234-5678-90ef-ghij-klmnopqrstuv`

### Descriptive Filename Format
- Path: `storage/descriptive/[hash_first2]/[hash_next2]/[descriptive_filename]`
- Example: `storage/descriptive/12/34/universe_name_character_name_blob_key.jpg`
- Filename includes: universe name, character names, blob key, and extension

## Cloud Storage
- Service: DigitalOcean Spaces (S3 compatible)
- Files stored with blob key as the object key
- Public access for serving images

## Usage Recommendations

### For Initial Production Migration
1. Run `rake images:diagnose` to understand current state
2. Review the diagnostic report carefully
3. Run `rake images:complete_migration` for full automated migration
4. Monitor logs for any errors and address them manually if needed

### For Ongoing Maintenance
- Run `rake images:diagnose` periodically to check system health
- Use `rake images:cleanup_orphaned` after bulk operations
- Use `rake images:regenerate_thumbnails` if thumbnail serving issues occur

## Error Handling

- All tasks include comprehensive error reporting
- Failed operations are logged with specific image IDs
- Size mismatches are detected and reported
- Missing files are identified for manual intervention

## Safety Features

- File size verification after all transfers
- Orphaned file identification before deletion
- Dry-run reporting in diagnostic mode
- Comprehensive logging of all operations

## Performance Considerations

- Tasks use `find_each` for memory-efficient batch processing
- Progress reporting every 50-100 images
- Parallel processing where safe (e.g., separate upload/download operations)
- Temporary files are properly cleaned up

## File Size Reporting

The cleanup task reports freed space in human-readable format (B, KB, MB, GB, TB).

## Monitoring

Each task provides:
- Start/end timestamps
- Success/error counts
- Detailed error messages with image IDs
- Progress indicators for long-running operations
- Summary reports with actionable recommendations

Run these tasks during maintenance windows in production to minimize impact on user experience.
