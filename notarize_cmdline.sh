#!/bin/zsh
set -euo pipefail
set -x
cd "$(dirname "$0")/dist/macos"
codesign -i com.mologie.NXBootCmd \
  -s "Developer ID Application: Oliver Kuckertz (N3S4C3QL65)" \
  -o kill,hard,library,runtime \
  --timestamp \
  --force \
  nxboot
rm -f nxboot.zip
zip nxboot.zip nxboot
xcrun notarytool submit --apple-id oliver@kuckertz.cloud --team-id N3S4C3QL65 --wait nxboot.zip
rm -f nxboot.zip
