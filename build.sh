#!/bin/bash

# Exit on error
set -e

# Print commands as they are executed for detailed Vercel logs
set -x

# Tell Flutter we are running in a non-interactive automated CI/CD bot environment
export CI=true
export BOT=true

echo "=== Checking Flutter SDK ==="
if [ -d "flutter" ]; then
  echo "=== Flutter directory exists, updating SDK ==="
  cd flutter
  git fetch origin
  git reset --hard origin/stable
  cd ..
else
  echo "=== Cloning Flutter SDK ==="
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# Build
echo "=== Building Flutter Web Application ==="
cd frontend
flutter pub get
flutter build web --release

echo "=== Build Completed Successfully ==="
