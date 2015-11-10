#!/bin/sh

# Created by David Edwards 
# This script is for MACS that have had a fresh OSX build applied from new or via recovery disk new with a local admin account created.
# Requires OSX 10.9 or higher.

echo "[I]Warning this script will hide the local admin account and reconfigure this device including enabling encryption. Please make a note of the encryption key"
read -p "Are you sure you want to continue (y/n)?" CONT
if [ "$CONT" == "y" ]; then
  
  
# Get the settings to be applied 
read -p "[!] Enter a name for this device: " DEVNAME
read -p "[!] Enter the username of the Local admin account: " ACCNAME

# Apply the settings 

echo "[I] Setting the computer name"
systemsetup -setcomputername "$DEVNAME"

echo "[I] Hide the local admin account "
dscl . create /Users/$ACCNAME IsHidden 1

echo "[I] The following command moves the home directory of  hiddenuser to /var, a hidden directory:"
mv /Users/$ACCNAME /var/$ACCNAME

echo "[I] Set the time zone to London"
/usr/sbin/systemsetup -settimezone "Europe/London"

# Switch on Apple Remote Desktop
# TBA

echo "[I] Enable SSH (TBA)"
systemsetup -setremotelogin on

# Configure Login Window to username and password text fields
# We might enable this later 
# /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

echo "[I] Enable admin info at the Login Window"
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "[I] Disable External Accounts at the Login Window"
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

# echo "[I] Disable iCloud for logging in users"
# Deleted as we want users to use a HO specific Icloud account for some things.

# echo "[I]Disable diagnostics"
# TODO, but this looks like its is set during first boot and is inherited by later users

echo "[I] Disabling password hints on lock screen"
defaults write com.apple.loginwindow RetriesUntilHint -int 0

echo "[I] Disable Time Machine Popups offering for new disks"
/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "[I] Enabling FileVault2 full disk encryption"
fdesetup enable -user $ACCNAME

echo "[I] Disabling infrared receiver"
# Turn off by default, users can re enable this if needed
defaults write com.apple.driver.AppleIRController DeviceEnabled -bool FALSE

echo "[I] Enabling scheduled updates"
softwareupdate --schedule on
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool true
defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdateRestartRequired -bool true
defaults write /Library/Preferences/com.apple.commerce.plist AutoUpdate -bool true

echo "[I] Enabling password-protected screen lock after 5 minutes"
systemsetup -setdisplaysleep 5
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "[I] Enabling firewall"
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
/usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

echo "[I] Launching firmware password utility (this may take a moment)"
diskutil mount Recovery\ HD
RECOVERY=$(hdiutil attach /Volumes/Recovery\ HD/com.apple.recovery.boot/BaseSystem.dmg | grep -i Base | cut -f 3)
open "$RECOVERY/Applications/Utilities/Firmware Password Utility.app"
echo "[!] Follow the prompts on the utility to set a strong unique firmware password"
echo "[!] Press enter when done"
read DONE

echo "[I] **** Finished ****"

else
  echo "Aborted";
fi

killall cfprefsd

exit 0
