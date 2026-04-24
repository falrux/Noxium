#!/bin/bash

# instead of making break lines, imma jst add comments atp

siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"

# dtc arch
arch=$(uname -m)

if [[ "$arch" == "arm64" ]]; then
    ROBLOX_APP="$siliconappPath"
else
    ROBLOX_APP="$intelappPath"
fi

# sudo prompt
sudo -v

# liveleak: robloxplayer dies in accident (ts a excuse to add another comment)
killall Roblox 2>/dev/null
killall RobloxPlayer 2>/dev/null

# codesigning
echo "recodesigning..."
sudo codesign --remove-signature "$ROBLOX_APP" 2>/dev/null || true
sudo codesign --force --deep --sign - "$ROBLOX_APP"

# bye bai
echo "ok open noxium and it should work now"
echo "made by @falrux"
