#!/bin/sh
# Rebuild "Pi Here.app" (droplet) from pi-here.applescript + icon.svg.
set -e
cd "$(dirname "$0")"
APP="$HOME/Applications/Pi Here.app"
WORK=$(mktemp -d)

magick -background none icon.svg -resize 1024x1024 "$WORK/icon.png"
mkdir "$WORK/i.iconset"
for s in 16 32 128 256 512; do
  sips -z $s $s "$WORK/icon.png" --out "$WORK/i.iconset/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$WORK/icon.png" --out "$WORK/i.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$WORK/i.iconset" -o "$WORK/icon.icns"

rm -rf "$APP"
osacompile -o "$APP" pi-here.applescript
cp pi-here.sh "$APP/Contents/Resources/pi-here.sh"
chmod +x "$APP/Contents/Resources/pi-here.sh"
cp "$WORK/icon.icns" "$APP/Contents/Resources/PiHere.icns"
rm -f "$APP/Contents/Resources/droplet.icns"
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile PiHere" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$APP/Contents/Info.plist" 2>/dev/null || true
codesign --force --deep -s - "$APP" 2>/dev/null
touch "$APP"
rm -rf "$WORK"
echo "built $APP"
