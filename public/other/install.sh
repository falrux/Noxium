#!/bin/bash

printf "%.0s\n" {1..50}
cd ~/

BLACK="\033[0;30m"
DARK_PURPLE="\033[0;35m"
PURPLE="\033[1;35m"
PINK="\033[1;38;5;206m"
CYAN="\033[1;36m"
GREEN="\033[0;32m"
RESET="\033[0m"
BOLD="\033[1m"
LARGE="\033[2J\033[0;0H"

noxapi="https://www.usenoxium.xyz/api/macversionrblx"
robloxapi="https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer"
noxexeczip="https://www.usenoxium.xyz/NoxiumExecutable.zip"
noxappzip="https://www.usenoxium.xyz/NoxiumApp.zip"
appPath="/Applications/Roblox.app"
noxdir="$HOME/Documents/Noxium"
execdir="$noxdir/Executable"
workdir="$noxdir/Workspace"
confdir="$noxdir/Config"
tmp="/tmp"

if [ -z "$appPath" ] || [ -z "$noxdir" ] || [ -z "$execdir" ]; then
    echo "Error"
    exit 1
fi

step() { echo -e "${BOLD}${DARK_PURPLE}▶ $1${RESET}"; }
ok() { echo -e "${BOLD}${GREEN}✓ $1${RESET}"; }
warn() { echo -e "${BOLD}${PURPLE}! $1${RESET}"; }
err() { echo -e "${BOLD}${CYAN}✘ $1${RESET}"; }

progress() {
    msg=$1
    echo -ne "${PURPLE}${msg}...${RESET}"
}

donep() {
    echo -e " ${PINK}done${RESET}"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    if [ "$current" -eq "$total" ]; then
        printf "\r${BOLD}${DARK_PURPLE}[%s%s] ${PINK}%d%%${RESET}\n" "$(printf "%.0s#" $(seq 1 $filled))" "$(printf "%.0s." $(seq 1 $empty))" "$percentage"
    else
        printf "\r${BOLD}${DARK_PURPLE}[%s%s] ${PINK}%d%%${RESET}" "$(printf "%.0s#" $(seq 1 $filled))" "$(printf "%.0s." $(seq 1 $empty))" "$percentage"
    fi
}

checkversions() {
    step "Checking versions"
    ternal_version=$(curl -s "$noxapi" 2>/dev/null)
    ro_versions=$(curl -s "$robloxapi" 2>/dev/null)
    ro_version=$(echo "$ro_versions" | grep -o '"clientVersionUpload":"[^"]*"' | cut -d'"' -f4)

    if [ "$ternal_version" == "$ro_version" ]; then
        ok "Versions match ($ternal_version)"
        echo
    else
        err "Version mismatch → Noxium: $ternal_version | Roblox: $ro_version"
        exit 1
    fi
}

getents() {
    step "Downloading entitlements"
    curl -s -L "https://www.usenoxium.xyz/api/ternal.entitlements" -o "./ternal.entitlements" 2>/dev/null

    ok "Completed"
    echo
}

installroblox() {
    step "Checking for Roblox..."

    found=false
    if [ -d "/Applications/RobloxPlayer.app" ]; then
        rm -rf "/Applications/RobloxPlayer.app" 2>/dev/null
        found=true
    fi
    if [ -d "/Applications/Roblox.app" ]; then
        rm -rf "/Applications/Roblox.app" 2>/dev/null
        found=true
    fi

    ok "Completed"
    echo

    arch=$(uname -m)
    
    if [ ! -d "$tmp" ]; then
        mkdir -p "$tmp"
    fi
    
    if [ "$arch" == "arm64" ]; then
        step "Downloading Roblox..."
        curl -L "https://setup.rbxcdn.com/mac/arm64/version-d0722e371e604117-RobloxPlayer.zip" -o "$tmp/RobloxPlayer.zip" 2>/dev/null >/dev/null
        echo
        ok "Completed"
    else
        step "Downloading Roblox..."
        curl -L "https://setup.rbxcdn.com/mac/version-d0722e371e604117-RobloxPlayer.zip" -o "$tmp/RobloxPlayer.zip" 2>/dev/null >/dev/null
        echo
        echo "you're on intel so uhhh, expect issues..."
        echo
        ok "Completed"
    fi

    if [ -f "$tmp/RobloxPlayer.zip" ]; then
        echo
        step "Installing Roblox..."
        unzip -o -q "$tmp/RobloxPlayer.zip" 2>/dev/null
        echo "nzip done"
        if [ -d "./RobloxPlayer.app" ]; then
            mv "./RobloxPlayer.app" "/Applications/Roblox.app" 2>/dev/null
        else
            echo -e " ${CYAN}✘${RESET}"
            err "Failed to extract Roblox"
        fi
        rm -f "$tmp/RobloxPlayer.zip"
    fi

    ok "Completed"
    echo
}

setupdirs() {
    step "Creating directories"
    mkdir -p "$execdir" "$workdir" "$confdir" 2>/dev/null
    ok "Completed"
    echo
}

installexecs() {
    step "Downloading executables"

    if [ -n "$execdir" ] && [ -d "$execdir" ]; then
        rm -rf "$execdir"/* 2>/dev/null
    fi

    zip_name="$execdir/noxium.zip"
    echo -ne "${DARK_PURPLE}Downloading...${RESET}"
    for i in {1..10}; do
        progress_bar $i 10
        sleep 0.05
    done
    curl -s -L "$noxexeczip" -o "$zip_name" 2>/dev/null

    ok "Completed"
    echo

    step "Extracting executables"

    unzip -o -q "$zip_name" -d "$execdir" 2>/dev/null

    if [ -n "$execdir" ] && [ -d "$execdir" ]; then
        find "$execdir" -type f ! -name "*.zip" -exec chmod +x {} \; 2>/dev/null
    fi
    if [ -n "$zip_name" ] && [ -f "$zip_name" ]; then
        rm -f "$zip_name"
    fi
    ok "Completed"
    echo
}

installapp() {
    step "Downloading Noxium..."

    if [ -e "/Applications/Noxium.app" ]; then
        rm -rf "/Applications/Noxium.app" 2>/dev/null
    fi

    zip_name="./Noxium.zip"
    echo -ne "${DARK_PURPLE}Downloading...${RESET}"
    for i in {1..10}; do
        progress_bar $i 10
        sleep 0.05
    done
    curl -s -L "$noxappzip" -o "$zip_name" 2>/dev/null

    ok "Completed"
    echo

    step "Installing Noxium..."

    unzip -o -q "$zip_name" 2>/dev/null
    app_found=$(find . -maxdepth 1 -name "Noxium.app" -type d | head -n 1)
    if [ -n "$app_found" ] && [ -d "$app_found" ]; then
        mv "$app_found" "/Applications/$app_found" 2>/dev/null
        ok "Completed"
        echo
    else
        echo -e " ${CYAN}✘${RESET}"
        err "Failed..."
    fi

    if [ -n "$zip_name" ] && [ -f "$zip_name" ]; then
        rm -f "$zip_name"
    fi
}

signroblox() {
    step "Signing Roblox"

    arch=$(uname -m)

    if [ "$arch" == "arm64" ] && [ -n "$appPath" ] && [ -e "$appPath" ]; then
        codesign --remove-signature "$appPath" 2>/dev/null
    fi

    if [ -n "$appPath" ] && [ -e "$appPath" ] && [ -f "./ternal.entitlements" ]; then
        codesign --force --deep --entitlements "./ternal.entitlements" -s - "$appPath" 2>/dev/null
    fi

    ok "Completed"
    echo
}

cleanup() {
    step "Cleaning up..."
    if [ -f "./ternal.entitlements" ]; then
        rm -f "./ternal.entitlements" 2>/dev/null
    fi
    ok "Completed"
    echo
}

pintodock() { 
    if [ -d "/Applications/Roblox.app" ]; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Roblox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    fi
    
    if [ -d "/Applications/Noxium.app" ]; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Noxium.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    fi
    
    killall Dock 2>/dev/null
}

echo -e "${BOLD}${PURPLE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET}"
echo -e "${BOLD}${DARK_PURPLE}       NOXIUM INSTALLER           ${RESET}"
echo -e "${BOLD}${PURPLE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RESET}"
echo
echo

setupdirs
installexecs
checkversions
getents 
installroblox
installapp
signroblox
cleanup
pintodock

step "Exiting"

echo
echo
echo
ok "Completed"
echo -e "${BOLD}${DARK_PURPLE}  Noxium MacOS Install Script Made By: @needrose${RESET}"
echo -e "${BOLD}${DARK_PURPLE}  Noxium MacOS Made By: @falrux/unknowingly_exists${RESET}"
echo
