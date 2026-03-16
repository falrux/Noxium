#!/bin/bash

siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"
noxdylib="$HOME/Documents/Noxium/Executable/libnoxium.dylib"



arch=$(uname -m)

if [[ "$arch" == "arm64" ]]; then
    ROBLOX_APP="$siliconappPath"
else
    ROBLOX_APP="$intelappPath"
fi



killall RobloxPlayer 2>/dev/null


echo "password is required for codesigning"
sudo codesign --remove-signature "$ROBLOX_APP"
sudo codesign --force --deep --sign - "$ROBLOX_APP"

codesign --force --deep --sign - "$noxdylib"
echo "ok codesigning done fr"



export DYLD_INSERT_LIBRARIES="$noxdylib"
echo "DYLIB INJECTED!"

"$ROBLOX_APP/Contents/MacOS/RobloxPlayer"


