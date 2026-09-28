#!/usr/bin/env bash
# Script for building Flutter Web on Render Static Site environment
set -e

echo "==> Checking Flutter SDK..."
if ! command -v flutter &> /dev/null; then
  echo "==> Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
  export PATH="$PATH:/tmp/flutter/bin"
fi

echo "==> Flutter Version:"
flutter --version

echo "==> Enabling Web & getting packages..."
flutter config --enable-web
flutter pub get

echo "==> Building Flutter Web Release..."
flutter build web --release --pwa-strategy=none

echo "==> Build complete! Output in build/web"
