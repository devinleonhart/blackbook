# Image Storage Migration Guide

This guide walks you through migrating from cloud-only storage to a hybrid local+cloud storage system, and eventually to local-only storage.

## Overview

The migration strategy involves:
1. **Phase 1**: Download all cloud images to local storage
2. **Phase 2**: Switch to hybrid mode (save to both, read local first)
3. **Phase 3**: Eventually switch to local-only (optional)

## Phase 1: Download Cloud Images

### 1. Run the Migration Script

```bash
# In production environment
rails images:migrate_to_local
```

This will:
- Download all cloud images to local storage
- Maintain the same Active Storage key structure
- Provide progress updates and error reporting
- Skip files that already exist locally

### 2. Verify Migration

```bash
# Check migration status
rails images:migration_status

# List any missing files
rails images:missing_local

# Check storage usage
rails images:storage_stats
```

### 3. Handle Failed Downloads

```bash
# Clean up corrupted files
rails images:cleanup_failed

# Retry migration for remaining files
rails images:migrate_to_local
```

## Phase 2: Enable Hybrid Storage

### 1. Update Production Configuration

Copy the hybrid configuration:
```bash
cp config/environments/production_hybrid.rb config/environments/production.rb
```

Or manually update `config/environments/production.rb`:
```ruby
# Change from:
config.active_storage.service = :digitalocean

# To:
config.active_storage.service = :hybrid
```

### 2. Deploy the Changes

Deploy your application with the new hybrid storage configuration.

### 3. Verify Hybrid Mode

After deployment, new images will be saved to both storages automatically. The system will:
- Try to serve images from local storage first
- Fallback to cloud storage if local is unavailable
- Save all new uploads to both locations

### 4. Monitor the System

Check logs for any storage issues:
```bash
# View image operation logs
tail -f log/images.log

# Check overall application logs
tail -f log/production.log
```

## Phase 3: Switch to Local-Only (Optional)

Once you're confident all images are available locally:

### 1. Update Configuration

```ruby
# In config/environments/production.rb
config.active_storage.service = :local_production
```

### 2. Verify Everything Works

Test that all images load correctly before proceeding.

### 3. Clean Up Cloud Storage

**⚠️ Warning: Only do this after thoroughly testing local-only mode**

You can now safely remove images from cloud storage if desired.

## Monitoring Commands

### Check Migration Progress
```bash
rails images:migration_status
```

### Find Missing Local Images
```bash
rails images:missing_local
```

### Storage Statistics
```bash
rails images:storage_stats
```

### Fix Failed Uploads
```bash
rails images:fix_failed_uploads
```

### Verify Individual Image
```ruby
# In Rails console
image = Image.find(123)
status = image.storage_status
puts "Local: #{status[:local]}, Cloud: #{status[:cloud]}"
```

## Troubleshooting

### Images Not Loading
1. Check if the file exists locally
2. Verify cloud storage credentials
3. Check application logs for errors
4. Try the `fix_failed_uploads` task

### Storage Space Issues
- Monitor disk usage during migration
- Consider downloading in smaller batches
- Ensure sufficient storage space before starting

### Performance Issues
- The migration script includes small delays to avoid overwhelming the system
- Run migration during low-traffic periods
- Monitor system resources during migration

### Reverting Changes
If you need to revert to cloud-only storage:

```ruby
# In config/environments/production.rb
config.active_storage.service = :digitalocean
```

Local files will remain but won't be used until you switch back to hybrid mode.

## File Structure

The local storage maintains the same structure as Active Storage's default:
```
storage/
├── 0a/
│   └── 30/
│       └── 0a30xfnily4t5m635a1gdsqacgps
├── 0l/
│   └── 72/
│       └── 0l723yad166yyas6kxmogw9k82vq
└── ...
```

## Security Considerations

- Local storage directory should not be web-accessible
- Maintain proper file permissions on the storage directory
- Consider backup strategies for local storage
- Monitor disk usage and implement log rotation

## Performance Benefits

After migration to local storage:
- Faster image loading (no network requests)
- Reduced bandwidth costs
- Better reliability (no dependency on external services)
- Improved privacy (images stay on your infrastructure)
