#!/usr/bin/env bash
set -o allexport

source .env

bash gitlab-knock.sh ${GITLAB_REPOSITORY_ID} ${GITLAB_REPOSITORY_BRANCH} "Local Test"
