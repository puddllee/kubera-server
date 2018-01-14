#!/bin/bash
set -e

if [[ $TRAVIS_BRANCH == "master" && $TRAVIS_PULL_REQUEST == "false" ]]; then

  echo "Starting deploying 🚀"

  eval "$(ssh-agent -s)"
  chmod 600 .travis/travis_dokku
  ssh-add .travis/travis_dokku
  ssh-keyscan jakerunzer.com >> ~/.ssh/known_hosts
  git remote add dokku dokku@jakerunzer.com:kubera-api
  git config --global push.default simple
  git push dokku master

  echo "Deployed 🤘"

else
  echo "Skipping deploy because build is not triggered from the master branch."
fi;
