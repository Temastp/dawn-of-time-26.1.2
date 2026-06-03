#!/usr/bin/env bash
set -e

# This script downloads Gradle 9.4 binary distribution and extracts
# gradle-wrapper.jar into gradle/wrapper/ so the Gradle wrapper works.
# Usage: ./scripts/fix-wrapper.sh

DIST_URL="https://services.gradle.org/distributions/gradle-9.4-bin.zip"
TMPDIR=$(mktemp -d)

echo "Downloading $DIST_URL..."
if command -v curl >/dev/null 2>&1; then
  curl -L -o "$TMPDIR/gradle-9.4-bin.zip" "$DIST_URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TMPDIR/gradle-9.4-bin.zip" "$DIST_URL"
else
  echo "Error: neither curl nor wget is available. Install one to proceed." >&2
  exit 1
fi

echo "Extracting gradle-wrapper.jar..."
if command -v unzip >/dev/null 2>&1; then
  unzip -j "$TMPDIR/gradle-9.4-bin.zip" "gradle-9.4/lib/gradle-wrapper.jar" -d gradle/wrapper
else
  # Try Python fallback
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import zipfile,sys
zipf=sys.argv[1]
with zipfile.ZipFile(zipf) as z:
    z.extract('gradle-9.4/lib/gradle-wrapper.jar', 'gradle_tmp')
PY
  fi
  mkdir -p gradle/wrapper
  mv gradle_tmp/gradle-9.4/lib/gradle-wrapper.jar gradle/wrapper/gradle-wrapper.jar
  rm -rf gradle_tmp
fi

echo "gradle-wrapper.jar installed to gradle/wrapper/gradle-wrapper.jar"
rm -rf "$TMPDIR"
