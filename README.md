# OSX-Provisioning

**Admin-setup.sh**

This script is designed to be run on a mac that is brand new, or had been rebuilt from a usb image. The script assumes the inital stages of first boot have been completed and that you have created a local admin account, are logged on and know the password for that. There should be no other accounts present, so runt his prior to creating any user accounts.

This will apply a number of security hardening settings, including applying full disk encryption wiht file vault. PLEASE make sure you make a note of the key that is shown on screen during this script running.

**check-byod**
This script, must be run as admin, and will check to see if a device has the required security applied. It does not change settings, only reports on them.

