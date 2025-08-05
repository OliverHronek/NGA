#!/bin/bash
# Script to fix all withOpacity deprecation warnings

echo "Fixing withOpacity deprecation warnings..."

# Array of files to fix
files=(
    "lib/presentation/screens/forum/forum_categories_screen.dart"
    "lib/presentation/screens/forum/create_category_screen.dart"
    "lib/presentation/screens/forum/forum_posts_screen.dart"
    "lib/presentation/screens/forum/post_detail_screen.dart"
)

# Backup and fix each file
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Fixing $file..."
        # Create backup
        cp "$file" "$file.backup"
        
        # Replace withOpacity with withValues
        sed -i 's/\.withOpacity(\([0-9.]*\))/\.withValues(alpha: \1)/g' "$file"
        
        echo "✅ Fixed $file"
    else
        echo "❌ File not found: $file"
    fi
done

echo "All withOpacity warnings should now be fixed!"
echo "Run 'flutter analyze' to verify."
