#!/bin/bash
# Alternative approach - Create a simple web server configuration

echo "Setting up Flutter Web for development..."

# Create a custom web configuration that bypasses CORS issues
cat > web_config.json << EOF
{
  "web": {
    "cors": {
      "enabled": false
    },
    "security": {
      "strictTransportSecurity": false
    }
  }
}
EOF

# Run flutter build web first to ensure everything is compiled
echo "Building web app..."
flutter build web --debug

# Then serve it locally
echo "Starting local web server..."
cd build/web
python -m http.server 3001

echo "App should be available at http://localhost:3001"
