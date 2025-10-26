#!/bin/bash

echo "🎨 Optimizing Images for APK Size Reduction..."
echo "================================================"

# Check if required tools are installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found. Installing..."
    echo "Please install ImageMagick:"
    echo "  - macOS: brew install imagemagick"
    echo "  - Ubuntu: sudo apt-get install imagemagick"
    echo "  - Windows: Download from https://imagemagick.org/script/download.php"
    exit 1
fi

# Create backup
echo "📦 Creating backup..."
mkdir -p assets_backup
cp -r assets assets_backup/

# Optimize PNG images (reduce quality while maintaining acceptable quality)
echo "🖼️  Optimizing PNG images..."
find assets/images -name "*.png" -exec convert {} -strip -quality 85 -define png:compression-filter=5 -define png:compression-level=9 {} \;
find assets/flags -name "*.png" -exec convert {} -strip -quality 80 -resize 80x80\> -define png:compression-filter=5 -define png:compression-level=9 {} \;

echo "✅ Image optimization complete!"
echo ""
echo "📊 Size comparison:"
du -sh assets_backup/assets
du -sh assets
echo ""
echo "💾 Backup saved in assets_backup/"
echo "⚠️  If images look bad, restore from backup: rm -rf assets && mv assets_backup/assets assets"

