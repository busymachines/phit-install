#!/bin/bash

# used only for cosmetic printouts in case no java is installed
PHIT_LATEST_JAVA='11.0.8.hs-adpt'

PHIT_ORIGINAL_WD=$(pwd)

PHIT_GIT_REPO='git@gitlab.com:busymachines/phit.git'
# for debugging the script or a new release, we might
# want to use a different branch than master
# end users have no reason to ever set this value
# so to debug, just do before running the script:
#
# export PHIT_OVERRIDE_GIT_CLONE_BRANCH='my-branch-name'
#
# then restart terminal, or run:
# unset PHIT_OVERRIDE_GIT_CLONE_BRANCH
#
if [ -n "$PHIT_OVERRIDE_GIT_CLONE_BRANCH" ]; then
  PHIT_GIT_CLONE_BRANCH="$PHIT_OVERRIDE_GIT_CLONE_BRANCH"
else
  PHIT_GIT_CLONE_BRANCH='master'
fi
PHIT_LATEST_VERSION='' # set in script after based on git tags

#where final instalations go to
PHIT_INSTALL_ROOT="$HOME/.sbt/phit"
PHIT_INSTALL_LOCATION='' # set in script after git clone

# this file contains everything that the user should add to their PATH
# to make phit available. The installer will prompt the user to add this
# to their .bashrc or .zrc or .bash_profile
# this is a stable way of the user loading _something_ this install
# script writes to their bash environment
PHIT_INSTALL_BASH_ENV_LOADER="$PHIT_INSTALL_ROOT/phit-load-env.sh"

#where temporary installation folders do to.
PHIT_INSTALL_TEMP_ROOT="$PHIT_INSTALL_ROOT/z-install-files"
PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER="$PHIT_INSTALL_TEMP_ROOT/phit-temp-clone"

PHIT_INSTALL_TEMP_SBT_BIN_FOLDER="$PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER/target/universal/stage"

PHIT_BACKUP_PATH="$PATH" # in case of any error exist, we make sure to reset the path
###############################################################################
################################### helpers ###################################
###############################################################################

function clean_up_temp_folder() {
  echo ""
  echo "🔥 Cleaning up temporary folders"
  echo "🔥 running:"
  echo "🔥   rm -rf $PHIT_INSTALL_TEMP_ROOT"
  echo ""

  cd "$PHIT_ORIGINAL_WD"
  rm -rf $PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER
  rm -rf $PHIT_INSTALL_TEMP_ROOT
}

function clean_up_env() {
  unset PHIT_ORIGINAL_WD
  unset PHIT_LATEST_JAVA
  unset PHIT_GIT_REPO
  unset PHIT_GIT_CLONE_BRANCH
  unset PHIT_LATEST_VERSION
  unset PHIT_INSTALL_ROOT
  unset PHIT_INSTALL_LOCATION
  unset PHIT_INSTALL_TEMP_ROOT
  unset PHIT_INSTALL_BASH_ENV_LOADER
  unset PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER
  unset PHIT_INSTALL_TEMP_SBT_BIN_FOLDER
}

function error_exit() {
  clean_up_temp_folder
  clean_up_env
  PATH="$PHIT_BACKUP_PATH"
  unset PHIT_BACKUP_PATH
}

echo ""
echo "🔥🔥 Attempting to install phit — the pureharm initialization tool 🔥🔥"
echo ""

###############################################################################
############################# prerequisite checks #############################
###############################################################################

if ! command -v git &>/dev/null; then
  echo "😭 "
  echo "😭 Could not find 'git' locally. For now, it is unfortunately required"
  echo "😭 "
  echo "😭 You will also need to have your git configured to access: "
  echo "😭 git@gitlab.com:busymachines/phit.git"
  echo "😭 via ssh"
  echo "😭 "

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

if ! command -v sbt &>/dev/null; then
  echo "😭 "
  echo "😭 Could not find 'sbt' locally. For now, it is unfortunately required"
  echo "😭 The recommended, and most cross-platform way, of installing it is is via sdkman"
  echo "😭"
  echo "😭 head on out to:"
  echo "😭 https://sdkman.io/install"
  echo "😭 "
  echo "😭 and after you have sdk man, install the Java version of your choice: "
  echo "😭   sdk list java"
  echo "😭   sdk install java $PHIT_LATEST_JAVA"
  echo "😭 "
  echo "😭   we might forget 👆👆👆👆👆👆👆 to update the latest version of java here"
  echo "😭   so please double check what you will be installing"
  echo "😭 "
  echo "😭 then install sbt:"
  echo "😭 https://www.scala-sbt.org/1.x/docs/Installing-sbt-on-Linux.html#Installing+from+SDKMAN"
  echo "😭 pasting this here for convenience:"
  echo "😭 "
  echo "😭 sdk install sbt"
  echo "😭 "
  #  echo "😭 🔥🔥🔥🔥🔥🔥"
  #  echo "😭 "
  #  echo "😭 Alternatively, use our script to do this work for you:"
  #  echo "😭 "
  #  echo '😭 curl -s "https://gitlab.com/busymachines/phit/-/tree/master/deploy/install-scripts/sbt-install-help.sh" | bash'
  #  echo "😭 "
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1

fi

###############################################################################
############################## installation stuff #############################
###############################################################################

# we just clean up temp root before trying anything
rm -rf "$PHIT_INSTALL_TEMP_ROOT"
mkdir -p "$PHIT_INSTALL_TEMP_ROOT"

echo ""
echo "🔥 Cloning phit repo from git: 🔥🔥"
echo "🔥   git clone -b $PHIT_GIT_CLONE_BRANCH $PHIT_GIT_REPO $PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER"

# we need to clone more of the repo, otherwise we won't have tags 😭
git clone -b "$PHIT_GIT_CLONE_BRANCH" $PHIT_GIT_REPO "$PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER" #--depth 1

if [ $? -eq 0 ]; then
  echo ""
  echo "🔥 git clone was a success. You will find the temp folder here: "
  echo "🔥   cd $PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER"
  echo "🔥 "
  echo "🔥 it should get cleaned up automatically... but you know"
  echo "🔥 imperative programming and resource management 😂😂🤣🤣😂"

  if [ -d "$PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER" ]; then
    cd "$PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER"
  else
    echo "😭 "
    echo "😭 git clone succeeded but for some reason: $PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER "
    echo "😭   does not exist. Can't do anything else... so giving up 😭"
    echo "😭 "
    echo "😭 Goodbye."
    echo ""

    error_exit
    # imperative programming :))
    # I can't abstract over this stuff
    # if you don't source the script, you can't 'return' :)
    return 1 2>/dev/null
    exit 1
  fi

else
  echo "😭 "
  echo "😭 git clone failed. Please make sure you have access rights to: "
  echo "😭   $PHIT_GIT_REPO"
  echo "😭 "
  echo "😭 Or if you manage to manually clone the repo, the just run:"
  echo "😭     sbt mkCLIBin"
  echo "😭 "
  echo "😭 And you should be good."
  echo "😭 Goodbye."
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1

fi

# if there is no parameter to the script
# determine latest from git tag
if [ -z "$1" ]; then
  # gets the most recent (git tag) <3, if it errors
  # out it redirects the stderr output to dev/null
  # https://stackoverflow.com/questions/44758736/redirect-stderr-to-dev-null
  # the output is usually due to the fact that there is no tag
  # rare case... but programming :( and it always prints out this:
  # fatal: No names found, cannot describe anything
  # which is annoying, to be honest, so we don't want that.
  git fetch --tags 1>/dev/null
  PHIT_LATEST_VERSION=$(git describe --abbrev=0 2>/dev/null)

  if [ $? -eq 0 ]; then
    echo "$PHIT_LATEST_VERSION"
    # nothing
  else
    PHIT_LATEST_VERSION="snapshot"
  fi
else
  PHIT_LATEST_VERSION="snapshot"
fi

PHIT_INSTALL_LOCATION="$PHIT_INSTALL_ROOT/$PHIT_LATEST_VERSION"

if [[ $PHIT_LATEST_VERSION == "snapshot" ]]; then
  echo ""
  echo "🔥 Installing latest and greatest $PHIT_LATEST_VERSION"
  echo "🔥 "
  echo "🔥 if you want to install a stable version, then just don't"
  echo "🔥 specify any parameter."
  echo "🔥 "
  echo "🔥 🤔🤔🤔 maybe we should allow users to specify a valid"
  echo "🔥 🤔🤔🤔 version so that they can install older versions too..."
  echo "🔥 🤔🤔🤔 too complicated for now, going for this easy route"
else
  # we force the repo at the tag version
  echo ""
  echo "🔥 Making sure we git back to the tag $PHIT_LATEST_VERSION"

  git reset --hard $PHIT_LATEST_VERSION >/dev/null

  echo ""
  echo "🔥 Installing latest stable version of phit: $PHIT_LATEST_VERSION"
  echo "🔥   to: $PHIT_INSTALL_LOCATION"
  echo "🔥 "
  echo "🔥 if you want to install the snapshot version, then provide"
  echo "🔥 literally any argument to the install script. Like, literally."
fi

if [ -d "$PHIT_INSTALL_LOCATION" ]; then
  echo ""
  echo "🔥 $PHIT_INSTALL_LOCATION"
  echo "🔥 👆👆 install location already exists, will be completely overridden"
  echo ""
fi

echo ""
echo "🔥 Running sbt... this might take a while... 😢"
echo "🔥 we've started it with the command:"
echo "🔥    sbt --error mkCLIBin"
echo "🔥 but for some reason this suppresses errors as well 😂😂"

sbt --error mkCLIBin

if [ $? -eq 0 ]; then
  echo ""
  echo "🔥 sbt packing was a success."
  echo ""
else
  echo ""
  echo "😭 "
  echo "😭 sbt packing failed for some reason."
  echo "😭 can you please do:"
  echo "😭   1) git clone -b $PHIT_GIT_CLONE_BRANCH $PHIT_GIT_REPO $PHIT_INSTALL_TEMP_GIT_CLONE_FOLDER"
  echo "😭   2) sbt mkCLIBin # in above clone"
  echo "😭 "
  echo "😭 and report it please 🥺"
  echo "😭 "
  echo "😭 Cleaning up as best we can..."
  echo "😭 "
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

if [ ! -d "$PHIT_INSTALL_TEMP_SBT_BIN_FOLDER" ]; then
  echo ""
  echo "😭 $PHIT_INSTALL_TEMP_SBT_BIN_FOLDER"
  echo "😭 👆👆 was not written by sbt, even though it should have been"
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

echo ""
echo "🔥 moving resulting installation files:"
echo "🔥   $PHIT_INSTALL_TEMP_SBT_BIN_FOLDER"
echo "🔥 to:"
echo "🔥   $PHIT_INSTALL_LOCATION"

rm -rf "$PHIT_INSTALL_LOCATION"

mkdir -p "$PHIT_INSTALL_ROOT"
if [ ! -d "$PHIT_INSTALL_ROOT" ]; then
  echo ""
  echo "😭 $PHIT_INSTALL_ROOT"
  echo "😭 👆👆 folder was not created. "
  echo "😭 Goodbye 😭"
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

mv "$PHIT_INSTALL_TEMP_SBT_BIN_FOLDER" "$PHIT_INSTALL_LOCATION"

if [ ! -d "$PHIT_INSTALL_LOCATION" ]; then
  echo ""
  echo "😭 $PHIT_INSTALL_LOCATION"
  echo "😭 👆👆was not written after attempting to move:"
  echo "😭    $PHIT_INSTALL_TEMP_SBT_BIN_FOLDER"
  echo "😭 "
  echo "😭 Goodbye 😭"
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

#replace the old env loader — or create new
if [ -f "$PHIT_INSTALL_BASH_ENV_LOADER" ]; then
  echo ""
  echo "🔥 $PHIT_INSTALL_BASH_ENV_LOADER"
  echo "🔥 👆👆 already exists, will be overridden"
  echo ""
  rm "$PHIT_INSTALL_BASH_ENV_LOADER"
fi

touch "$PHIT_INSTALL_BASH_ENV_LOADER"
chmod u+x "$PHIT_INSTALL_BASH_ENV_LOADER"

PHIT_TEMP_EXPORT_NEW_PATH_COMMAND="export PATH=\"$PHIT_INSTALL_LOCATION/bin::\$PATH\""

echo "#!/bin/bash" >>"$PHIT_INSTALL_BASH_ENV_LOADER"
echo "$PHIT_TEMP_EXPORT_NEW_PATH_COMMAND" >>"$PHIT_INSTALL_BASH_ENV_LOADER"
echo "" >>"$PHIT_INSTALL_BASH_ENV_LOADER"

unset PHIT_TEMP_EXPORT_NEW_PATH_COMMAND

if [ ! -f "$PHIT_INSTALL_BASH_ENV_LOADER" ]; then
  echo ""
  echo "😭 $PHIT_INSTALL_BASH_ENV_LOADER"
  echo "😭 👆👆 was not written, even though it should have been"
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

# load the new PATH — requires the user to have invoked this
# script w/ source though. Otherwise this is useless.
# that's why in the README we recommend using source
source "$PHIT_INSTALL_BASH_ENV_LOADER"

clean_up_temp_folder

echo ""
echo "🔥 phit installation complete @:"
echo "🔥 👉👉👉   $PHIT_INSTALL_LOCATION"
echo "🔥 "
echo "🔥 👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇"
echo "🔥 To have the 'phit' command available after this terminal"
echo "🔥 session, and for every new phit installation from now on"
echo "🔥 "
echo "🔥 please make sure that your OS dependent terminal profile:"
echo "🔥 👉👉👉     ~/.bash_profile ; or ; ~/.zshrc ; or ; ~/.bashrc "
echo "🔥 has the following:"
echo "🔥 👉👉👉     source $PHIT_INSTALL_BASH_ENV_LOADER"
echo "🔥 "
echo "🔥 The install script will always write that file to point"
echo "🔥 to the latest installed phit. So you only have to do this"
echo "🔥 once per terminal profile lifetime. And phit will keep"
echo "🔥 updating."
echo "🔥 👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆"


clean_up_env
unset PHIT_BACKUP_PATH

echo ""
echo "🔥 Thank you for using phit, you should now be able to just run"
echo "🔥    phit"
echo "🔥 for further instructions simply run it and it will print out"
echo "🔥 emoji rich instructions."
echo "🔥 "
echo "🔥 thank you for understanding that installing stuff is the worst"
echo "🔥 and we're genuinely trying our best ☺️"
echo "🔥 "
echo "🔥 ❤️ 🖤 💚 💜"
echo ""
