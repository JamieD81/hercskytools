#!/bin/bash

unset SUCCESS
on_exit() {
  if [ -z "$SUCCESS" ]; then
    echo "ERROR: $0 failed.  Please fix the above error."
    exit 1
  else
    echo "SUCCESS: $0 has completed."
    exit 0
  fi
}
trap on_exit EXIT

http_patch() {
  PATCHNAME=$(basename $1)
  curl -L -o $PATCHNAME -O -L $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

# Change directory verbose
cdv() {
  echo
  echo "*****************************"
  echo "Current Directory: $1"
  echo "*****************************"
  cd $BASEDIR/$1
}

# Change back to base directory
cdb() {
  cd $BASEDIR
}

# Sanity check
if [ -d ../.repo ]; then
  cd ..
fi
if [ ! -d .repo ]; then
  echo "ERROR: Must run this script from the base of the repo."
  SUCCESS=true
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
repo abandon auto
set -e

################ Apply Patches Below ####################

repo start auto device/samsung/skyrocket
cdv device/samsung/skyrocket
echo "### skyrocket: build kernel from source (DO NOT MERGE!) http://review.cyanogenmod.com/#/c/17430/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_skyrocket refs/changes/30/17430/1 && git cherry-pick FETCH_HEAD
cdb 

repo start auto device/samsung/skyrocket
cdv device/samsung/skyrocket
echo "### skyrocket: enable LPA playback http://review.cyanogenmod.com/#/c/17625/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_device_samsung_skyrocket refs/changes/25/17625/1 && git cherry-pick FETCH_HEAD
cdb 

##### SUCCESS ####
SUCCESS=true
exit 0
