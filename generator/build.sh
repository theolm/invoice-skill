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
echo "3. Copying to invoice-pdf/bin/..."
cp bin/generate_invoice ../invoice-pdf/bin/generate_invoice

echo ""
echo "Done!"
echo "  Binary:          bin/generate_invoice"
echo "  Skill binary:    ../invoice-pdf/bin/generate_invoice"
echo ""
echo "Usage: ./bin/generate_invoice --data='{\"key\": \"value\"}'"
