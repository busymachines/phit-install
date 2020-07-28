#!/bin/bash

# for debugging the script or a new release, we might
# want to use a different branch than master
# end users have no reason to ever set this value
if [ -n "$PHIT_OVERRIDE_GIT_CLONE_BRANCH" ]; then
  PHIT_GIT_CLONE_BRANCH="$PHIT_OVERRIDE_GIT_CLONE_BRANCH"
else
  PHIT_GIT_CLONE_BRANCH='master'
fi

# this should always be set to the the latest STABLE tag in our github repo
LATEST_JAVA='11.0.8.hs-adpt'
GIT_REPO='git@gitlab.com:busymachines/phit.git'
LATEST_PHIT=''# set in script after based on git repo

#where final instalations go to
PHIT_INSTALL_ROOT="$HOME/.sbt/phit"
PHIT_INSTALL_LOCATION='' # set in script after git clone

#where temporary installation folders do to.
PHIT_INSTALL_TEMP_ROOT="$PHIT_INSTALL_ROOT/z-install-files"

# this file contains everything that the user should add to their PATH
# to make phit available. The installer will prompt the user to add this
# to their .bashrc or .zrc or .bash_profile
# this is a stable way of the user loading _something_ this install
# script writes to their bash environment
PHIT_INSTALL_BASH_ENV_LOADER="$PHIT_INSTALL_ROOT/phit-load-env.sh"

ORIGINAL_LOCATION=$(pwd)

TEMP_PHIT_FOLDER="$PHIT_INSTALL_TEMP_ROOT/phit_temp_install"
PHIT_SBT_BIN_FOLDER="$TEMP_PHIT_FOLDER/target/universal/stage"

###############################################################################
################################### helpers ###################################
###############################################################################

function clean_up_temp_folder() {
  echo ""
  echo "🔥 Cleaning up temporary git clone"
  echo "🔥 running:"
  echo "🔥   rm -rf $TEMP_PHIT_FOLDER"
  echo ""

  cd "$ORIGINAL_LOCATION"
  rm -rf $TEMP_PHIT_FOLDER
  rm -rf $PHIT_INSTALL_TEMP_ROOT
}

function error_exit() {
  clean_up_temp_folder
}

function happy_exit() {
  clean_up_temp_folder
}

echo ""
echo "🔥🔥 Attempting to install phit — the pureharm initialization tool 🔥🔥"
echo ""

###############################################################################
############################# prerequisite checks #############################
###############################################################################

if ! command -v git &>/dev/null; then
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
  echo "😭 Could not find 'sbt' locally. For now, it is unfortunately required"
  echo "😭 The recommended, and most cross-platform way, of installing it is is via sdkman"
  echo "😭"
  echo "😭 head on out to:"
  echo "😭 https://sdkman.io/install"
  echo "😭 "
  echo "😭 and after you have sdk man, install the Java version of your choice: "
  echo "😭   sdk list java"
  echo "😭   sdk install java $LATEST_JAVA"
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
echo "🔥🔥 Cloning phit repo from git: 🔥🔥"
echo "🔥🔥  🔥git clone -b $PHIT_GIT_CLONE_BRANCH $GIT_REPO $TEMP_PHIT_FOLDER"
echo ""

# we need to clone more of the repo, otherwise we won't have tags 😭
git clone -b "$PHIT_GIT_CLONE_BRANCH" $GIT_REPO "$TEMP_PHIT_FOLDER" #--depth 1

if [ $? -eq 0 ]; then
  echo ""
  echo "🔥 git clone was a success. You will find the temp folder here: "
  echo "🔥   cd $TEMP_PHIT_FOLDER"
  echo "🔥 "
  echo "🔥 it should get cleaned up automatically... but you know"
  echo "🔥 imperative programming and resource management 😂😂🤣🤣😂"
  echo ""

  if [ -d "$TEMP_PHIT_FOLDER" ]; then
    cd "$TEMP_PHIT_FOLDER" || ([[ -v $PS1 ]] && return 1 || exit 1)
  else
    echo ""
    echo "😭 git clone succeeded but for some reason: $TEMP_PHIT_FOLDER "
    echo "😭   does not exist. Can't do anything else... so giving up 😭"
    echo "😭 "
    echo "😭 Goodbye."

    error_exit
    # imperative programming :))
    # I can't abstract over this stuff
    # if you don't source the script, you can't 'return' :)
    return 1 2>/dev/null
    exit 1
  fi

else
  echo ""
  echo "😭 git clone failed. Please make sure you have access rights to: "
  echo "😭   $GIT_REPO"
  echo "😭 "
  echo "😭 Or if you manage to manually clone the repo, the just run:"
  echo "😭     sbt stage"
  echo "😭 "
  echo "😭 And you should be good."
  echo "😭 Goodbye."

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1

fi

git fetch --tags

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
  LATEST_PHIT=$(git describe --abbrev=0 2>/dev/null)

  if [ $? -eq 0 ]; then
    echo "$LATEST_PHIT"
    # nothing
  else
    LATEST_PHIT="snapshot"
  fi
else
  LATEST_PHIT="snapshot"
fi

PHIT_INSTALL_LOCATION="$PHIT_INSTALL_ROOT/$LATEST_PHIT"

if [[ $LATEST_PHIT == "snapshot" ]]; then
  echo ""
  echo "🔥 Installing latest and greatest $LATEST_PHIT"
  echo "🔥 "
  echo "🔥 if you want to install a stable version, then just don't"
  echo "🔥 specify any parameter."
  echo "🔥 "
  echo "🔥 🤔🤔🤔 maybe we should allow users to specify a valid"
  echo "🔥 🤔🤔🤔 version so that they can install older versions too..."
  echo "🔥 🤔🤔🤔 too complicated for now, going for this easy route"
  echo ""
else
  # we force the repo at the tag version
  echo ""
  echo "🔥 Making sure we git back to the tag $LATEST_PHIT"
  echo ""

  git reset --hard $LATEST_PHIT >/dev/null

  echo ""
  echo "🔥 Installing latest stable version of phit: $LATEST_PHIT"
  echo "🔥   to: $PHIT_INSTALL_LOCATION"
  echo "🔥 "
  echo "🔥 if you want to install the snapshot version, then provide"
  echo "🔥 literally any argument to the install script. Like, literally."
  echo "🔥 "
  echo ""
fi

if [ -d "$PHIT_INSTALL_LOCATION" ]; then
  echo ""
  echo "🔥 $PHIT_INSTALL_LOCATION"
  echo "🔥 👆👆 install location already exists, will be completely overridden"
  echo ""
fi

echo ""
echo "🔥 Starting sbt... this might take a while... 😢"
echo ""

sbt mkCLIBin

if [ $? -eq 0 ]; then
  echo ""
  echo "🔥 sbt packing was a success."
  echo ""
else
  echo ""
  echo "😭 sbt packing failed for some reason. See above sbt horrid output to"
  echo "😭 find the reason, and report it please"
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

echo ""
echo "🔥 moving files to:"
echo "🔥  $PHIT_INSTALL_LOCATION"
echo ""

if [ ! -d "$PHIT_SBT_BIN_FOLDER" ]; then
  echo ""
  echo "😭 $PHIT_SBT_BIN_FOLDER"
  echo "😭 👆👆 was not written by sbt, even though it should have been"
  echo ""

  error_exit
  # imperative programming :))
  # I can't abstract over this stuff
  # if you don't source the script, you can't 'return' :)
  return 1 2>/dev/null
  exit 1
fi

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

mv "$PHIT_SBT_BIN_FOLDER" "$PHIT_INSTALL_LOCATION"

if [ ! -d "$PHIT_INSTALL_LOCATION" ]; then
  echo ""
  echo "😭 $PHIT_INSTALL_LOCATION"
  echo "😭 👆👆was not written after attempting to move:"
  echo "😭    $PHIT_SBT_BIN_FOLDER"
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

EXPORT_NEW_PATH_COMMAND="export PATH=\"$PHIT_INSTALL_LOCATION/bin::\$PATH\""

echo "#!/bin/bash" >>"$PHIT_INSTALL_BASH_ENV_LOADER"
echo "$EXPORT_NEW_PATH_COMMAND" >>"$PHIT_INSTALL_BASH_ENV_LOADER"
echo "" >>"$PHIT_INSTALL_BASH_ENV_LOADER"

unset EXPORT_NEW_PATH_COMMAND

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

happy_exit

echo ""
echo ""
echo "🔥 phit installation complete @:"
echo "🔥 $PHIT_INSTALL_LOCATION"
echo "🔥 "
echo "🔥 👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇"
echo "🔥 To have the 'phit' command available after this terminal"
echo "🔥 session, and for every new phit installation from now on"
echo "🔥 "
echo "🔥 please make sure that your OS dependent terminal profile:"
echo "🔥   ~/.bash_profile ; or ; ~/.zshrc ; or ; ~/.bashrc "
echo "🔥 has the following:"
echo "🔥   . $PHIT_INSTALL_BASH_ENV_LOADER"
echo "🔥 "
echo "🔥 The install script will always write that file to point"
echo "🔥 to the latest installed phit. So you only have to do this"
echo "🔥 once per terminal profile lifetime. And phit will keep"
echo "🔥 updating."
echo "🔥 👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆👆"
echo ""

echo ""
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
