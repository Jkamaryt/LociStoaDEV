#!/bin/zsh
set -e

PROJECT_DIR="/Users/jwk/Desktop/LociStoa"
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

echo "===================================================="
echo "  LociStoa — Local / Private iOS Installer & Tester"
echo "===================================================="

# Check if a physical iPhone or iPad is currently connected with Developer Mode enabled (DDI mounted)
CONNECTED_IOS=$(xcrun devicectl list devices 2>/dev/null | grep -w "physical" | grep -w "connected" | grep -v "no DDI" | head -n 1 || true)

if [[ -n "$CONNECTED_IOS" ]]; then
  DEVICE_UDID=$(echo "$CONNECTED_IOS" | grep -oE '[0-9A-F]{8}-[0-9A-F]{16}' | head -n 1)
  echo "Found physical iOS device: $CONNECTED_IOS"
  echo "Registering device, signing with your Personal Team (L2X9U77KFN), and installing..."
  xcodebuild -project "$PROJECT_DIR/LociStoa.xcodeproj" \
    -scheme LociStoa \
    -configuration Debug \
    -destination "id=$DEVICE_UDID" \
    -derivedDataPath "$PROJECT_DIR/build/DerivedData" \
    -allowProvisioningUpdates \
    -allowProvisioningDeviceRegistration \
    build
  xcrun devicectl device install app --device "$DEVICE_UDID" "$PROJECT_DIR/build/DerivedData/Build/Products/Debug-iphoneos/LociStoa.app"
  xcrun devicectl device process launch --device "$DEVICE_UDID" com.jackkamaryt.locistoa.app
  echo "Successfully installed and launched LociStoa on your iOS device!"
else
  echo "No physical iPhone/iPad currently plugged in. Booting local iPhone 18 Pro Max Simulator..."
  SIM_UDID="6196369A-6105-4971-9EA2-13EEEC350F26"
  xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
  open -a "/Applications/Xcode.app/Contents/Applications/DeviceHub.app" 2>/dev/null || true
  xcodebuild -project "$PROJECT_DIR/LociStoa.xcodeproj" \
    -scheme LociStoa \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$SIM_UDID" \
    -derivedDataPath "$PROJECT_DIR/build/DerivedData" \
    build | tail -n 5
  xcrun simctl install "$SIM_UDID" "$PROJECT_DIR/build/DerivedData/Build/Products/Debug-iphonesimulator/LociStoa.app"
  xcrun simctl launch "$SIM_UDID" com.jackkamaryt.locistoa.app
  echo "LociStoa is now installed and running in the iPhone 18 Pro Max Simulator!"
fi
