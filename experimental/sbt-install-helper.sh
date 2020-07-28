#!/bin/bash

##### FIXME #####
#####
##### For some reason running
##### sdk java install ....
##### keeps complaining "command not found 'sdk'... even though it's a function,
##### and it definitely exists since we make that check on line 37
#####

LATEST_JAVA='11.0.8.hs-adpt'

if command -v sdk &>/dev/null; then
  echo ""
  echo "😳 Wait, why are you trying to install sdk man if you already have it?"
  echo "😳 'sdk' in your terminal should work"
  exit
fi

echo ""
echo "🔥 Installing sdkman. Thank you for trusting phit 😊😊"
echo '🔥 Running: curl -s "https://get.sdkman.io" | bash'
echo ""

#curl -s "https://get.sdkman.io" | bash

echo ""
echo "🔥 So far so good, phit script continues..."
echo ""
echo '🔥 Running: source "$HOME/.sdkman/bin/sdkman-init.sh"'
echo ""

#source "$HOME/.sdkman/bin/sdkman-init.sh"

# for some reason sdk is installed as a bash function, not an executable, so command doesn't work.
# https://stackoverflow.com/questions/1007538/check-if-a-function-exists-from-a-bash-script
if !type sdk &>/dev/null; then
  echo ""
  echo "😭 Could not find installation of 'sdk' ..."
  echo "😭 sorry, you'll have to debug it now."
  exit
fi

echo ""
echo "🔥 So far so good, phit attempts to install Java ..."
echo ""
echo "🔥 Running: sdk install java $LATEST_JAVA"
echo ""

'sdk' java install $LATEST_JAVA

echo ""
echo "🔥 So far so good, phit attempts to install sbt ..."
echo ""
echo "🔥 Running: sdk sbt install"
echo ""

sdk sbt install

if ! command -v sbt &>/dev/null; then
  echo ""
  echo "😭 Could not find 'sbt' ... sorry, you'll have to debug it now :("
  echo "😭"
  echo ""
  exit
fi

echo ""
echo "🔥 All right, you can try running the phit install script again 😌😌"
echo '🔥 curl -s "https://gitlab.com/busymachines/phit/-/tree/master/deploy/install-scripts/phit-install-script.sh" | bash'
echo ""
