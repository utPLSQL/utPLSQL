#!/bin/bash
 
# Many aspsects of this came from https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
# Significant alterations
# - Avoid pulling all history for cloned repo 
# - Support for multiple copies of documenation, 
#   - only clearing out latest
#   - doc-history.md logging doc history
# - Wrapped calls with actual encrypt keys with > /dev/null 2> /dev/null4

# How to run: 
#  - From repository root .travis/push_docs_to_gh_pages.sh

# Required files / directories (relative from repo root)
# - Folder : "site" with that contains latest docs
# - File   : ".travis/deploy_key.enc" SSH deployment key encrypted by Travis command line tool 

# Required ENV Variables
#  ENCRYPTION_LABEL  - Manually Set in travis web settings.  Value can be displayed in LOG
#  encrypted_${ENCRYPTION_LABEL}_key - Set in web settings using travis cmdline encryption
#  encrypted_${ENCRYPTION_LABEL}_iv  - Set in web settings using travis cmdline encryption 
#  PAGES_TARGET_BRANCH="gh-pages"   - Set in .travis.yml, branch were pages will be deployed
#  PAGES_VERSION_BASE="version3" -Set in .travis.yml, directory for pages deployment
#  TRAVIS_* variables are set by travis directly and only need to be if testing externally

# Pull requests are special...
# They won't have acceess to the encrypted variables.
# This prevent access to the Encrypted SSH Key
# Regardless we don't want a pull request automatically updating the repository 
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then  

  # ENV Variable checks are to help with configuration troubleshooting
  # they silently exit with unique message.  Anyone one of them not set
  # can be used to turn off this functionality.  
  # For example a feature branch in the master repository that we don't want docs produced for yet.  
  [[ -n "$PAGES_VERSION_BASE" ]] || { echo "PAGES_VERSION_BASE Missing";  exit 0; }
  [[ -n "$PAGES_TARGET_BRANCH" ]] || { echo "PAGES_TARGET_BRANCH Missing";  exit 0; }
  [[ -n "$ENCRYPTION_LABEL" ]] || { echo "ENCRYPTION_LABEL Missing";  exit 0; }
 
  # Fail because required script to generate documenation must have not been run, or was changed.
  [[ -d ./site ]] || { echo "site directory not found";  exit 1; }
  
  # Save some useful information
  REPO=`git config remote.origin.url`
  SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
  SHA=`git rev-parse --verify HEAD`

  # shallow clone the repostoriy and switch to PAGES_TARGET_BRANCH branch
  mkdir pages
  cd pages
  git clone --depth 1 $REPO .
  PAGES_BRANCH_EXISTS=$(git ls-remote --heads $REPO $PAGES_TARGET_BRANCH)
 
  if [ -n "$PAGES_BRANCH_EXISTS" ] ; then
    echo "Pages Branch Found"
    echo "-$PAGES_BRANCH_EXISTS-"
    git remote set-branches origin  $PAGES_TARGET_BRANCH
    git fetch --depth 1 origin $PAGES_TARGET_BRANCH 
    git checkout $PAGES_TARGET_BRANCH  
  else
    echo "Creating Pages Branch"
    git checkout --orphan $PAGES_TARGET_BRANCH 
    git rm -rf .  
  fi  
    
  #clear out latest and copy site contents to it.  
  echo "updating $VERSION_BASE/latest"
  mkdir -p $PAGES_VERSION_BASE/latest 
  rm -rf $PAGES_VERSION_BASE/latest/**./* || exit 0
  cp -a ../site/. $PAGES_VERSION_BASE/latest 
  
  # If a Tagged Build then copy to it's own directory as well.
  if [ -n "$TRAVIS_TAG" ]; then
   echo "Creating $PAGES_VERSION_BASE/$TRAVIS_TAG"
   mkdir -p $PAGES_VERSION_BASE/$TRAVIS_TAG || exit 0
    cp -a ../site/. $PAGES_VERSION_BASE/$TRAVIS_TAG 
  fi
 
  #Check if there are doc changes, if none exit the script
  if [[ -z `git diff --exit-code` ]] && [ -n "$PAGES_BRANCH_EXISTS" ] ; then
    echo "No changes to docs detected."
    exit 0
  fi

  #Chganges where detected, so it's safe to write to log.
  now=$(date +"%d %b %Y - %r")
  export latest=" - [Latest Doc Change]($PAGES_VERSION_BASE/latest/) - Created $now"  
  if [ ! -f doc-history.md ]; then
    echo "<!-- Auto generated in .travis/push_docs_to_gh_pages.sh -->" >doc-history.md
    echo "#Doc Generation Log" >>doc-history.md
    echo "" >>doc-history.md
    echo "- 4th line placeholder see below" >>doc-history.md
    echo "" >>doc-history.md
    echo "##Released Version Doc History" >>doc-history.md
    echo "" >>doc-history.md
  fi 
  if [ -n "$TRAVIS_TAG" ]; then
    echo " - [$TRAVIS_TAG]($PAGES_VERSION_BASE/$TRAVIS_TAG/) - Created $now" >>doc-history.md
  fi  
  
  #replace 4th line in log
  sed -i '4s@.*@'"$latest"'@'  doc-history.md 

  #Setup Git with Commiter info
  git config user.name "Travis CI"
  git config user.email "utplsql@users.noreply.github.com"

  #Add and Commit the changes back to pages repo.
  git add .
  git commit -m "Deploy to GitHub Pages: ${SHA}"
  
  #unencrypt and configure deployment key
  [[ -e ../.travis/deploy_key.enc ]] || { echo ".travis/deploy_key.enc file not found";  exit 1; }
  ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
  ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
  ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR} > /dev/null 2> /dev/null
  ENCRYPTED_IV=${!ENCRYPTED_IV_VAR} > /dev/null 2> /dev/null
  openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ../.travis/deploy_key.enc -out  ../.travis/deploy_key -d > /dev/null 2> /dev/null
  chmod 600 ../.travis/deploy_key
  eval `ssh-agent -s`
  ssh-add ../.travis/deploy_key  
  
  # Now that we're all set up, we can push.
  echo "git push $SSH_REPO $PAGES_TARGET_BRANCH"
  git push $SSH_REPO $PAGES_TARGET_BRANCH    
fi
