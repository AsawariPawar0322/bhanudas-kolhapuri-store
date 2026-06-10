#!/bin/bash

# Exit on error
set -e

echo "=== Downloading Flutter SDK ==="
# Clone Flutter stable branch with depth 1 for faster download
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH
export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Verifying Flutter Installation ==="
flutter doctor

echo "=== Building Flutter Web Application ==="
cd frontend
flutter pub get
flutter build web --release --web-renderer canvaskit

echo "=== Build Completed Successfully ==="
