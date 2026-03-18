#!/bin/bash

# instead of making break lines, imma jst add comments atp

siliconappPath="/Applications/Roblox.app"
intelappPath="/Applications/RobloxPlayer.app"
noxdylib="$HOME/Documents/Noxium/Executable/libnoxium.dylib"
noxtmp="/private/tmp/noxium"

# dtc arch
arch=$(uname -m)

if [[ "$arch" == "arm64" ]]; then
    ROBLOX_APP="$siliconappPath"
else
    ROBLOX_APP="$intelappPath"
    echo "aw hell naw ts nga using intel :sob::pray:"
fi

# sudo prompt
echo "enter yo password plz"
sudo -v

# ui & esp communication fix
echo "fixing esp communication shits..."
if [[ -d "$noxtmp" ]]; then
    sudo rm -rf "$noxtmp"
fi

sudo mkdir -p "$noxtmp"
sudo chmod -R 777 "$noxtmp"

# liveleak: robloxplayer dies in accident (ts a excuse to add another comment)
killall RobloxPlayer 2>/dev/null

# codesigning
echo "recodesigning..."
sudo codesign --remove-signature "$ROBLOX_APP"
sudo codesign --force --deep --sign - "$ROBLOX_APP"

codesign --force --deep --sign - "$noxdylib"

# bye bai
echo "ok open noxium and it should work now"
echo "made by @falrux"
