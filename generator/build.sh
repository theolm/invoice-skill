#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Invoice Generator Build ==="
echo ""

echo "1. Installing dependencies..."
dart pub get

echo ""
echo "2. Compiling binary..."
dart compile exe bin/generate_invoice.dart -o bin/generate_invoice

echo ""
echo "3. Copying to skill/bin/..."
cp bin/generate_invoice ../skill/bin/generate_invoice

echo ""
echo "Done!"
echo "  Binary:          bin/generate_invoice"
echo "  Skill binary:    ../skill/bin/generate_invoice"
echo ""
echo "Usage: ./bin/generate_invoice --data='{\"key\": \"value\"}'"
