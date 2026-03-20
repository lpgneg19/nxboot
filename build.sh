#!/bin/zsh
set -euo pipefail

# Ensure the project is up to date
xcodegen generate

target_property() {
  bundle exec xcodeproj show NXBoot.xcodeproj --no-ansi --format=tree_hash \
    | yj \
    | jq -r \
      '.rootObject.targets[]
      |select(.name=="NXBootApp")
      |.buildConfigurationList.buildConfigurations[]
      |select(.name=="Release").buildSettings.'$1
}

version=$(target_property MARKETING_VERSION)
buildno=$(target_property CURRENT_PROJECT_VERSION)
distdir=dist
tmpdir=DerivedData/bin
mkdir -p $distdir/macos

#
# macOS app build
#

echo "Building macOS application..."
xcodebuild -scheme NXBootApp -configuration Release -destination "platform=macOS" clean build
ditto DerivedData/NXBoot/Build/Products/Release/NXBootApp.app "$distdir/macos/NXBootApp.app"

#
# command line tool build (macOS)
#

echo "Building nxboot macOS tool..."
xcodebuild -scheme NXBootCmd -configuration Release -destination "platform=macOS" clean build
install DerivedData/NXBoot/Build/Products/Release/nxboot "$distdir/macos/nxboot"

echo "All done, results are available at $distdir/"
