#!/bin/bash
TOKEN_FILE=~/github-token
ARTIFACT_ACCOUNT_NAME=my-github-artifact-account

if [ ! -e "$TOKEN_FILE" ] ; then
  echo "token file does not exist"
  exit 1
fi

hal config features edit --artifacts true
hal config artifact github enable
hal config artifact github account add $ARTIFACT_ACCOUNT_NAME \
    --token-file $TOKEN_FILE

# webhook address: http://ip:8084/webhooks/git/github
