#!/bin/bash

function setupGit() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

function tagVersion() {
  TAG=$1

  git tag $TAG -a -m "Release version $TAG"
  git push origin $TAG
}

function main() {
  BRANCH=""
  TAG=""

  cd ./mpro

  BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [ "$BRANCH" = "ci-test" ]; then
    TAG=$(bash ./mpro/scripts/appVersion.sh --version)

    setupGit
    tagVersion $TAG
  fi

  cd ..
  rm -rf mpro

  exit 0
}

main