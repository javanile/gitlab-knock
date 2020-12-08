#!/usr/bin/env bash

##
# gitlab-knock.sh
#
# Copyright (c) 2020 Francesco Bianco <bianco@javanile.org>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
##

set -e

VERSION=0.1.0
GITLAB_PROJECT_API_URL="https://gitlab.com/api/v4/projects"

usage () {
    echo "Usage: ./gitlab-knock.sh [OPTION]... [COMMAND] [ARGUMENT]..."
    echo ""
    echo "Support your CI workflow with useful macro."
    echo ""
    echo "List of available commands"
    echo "  create:branch NAME REF            Create new branch with NAME from REF"
    echo "  create:file NAME CONTENT BRANCH   Create new file with NAME and CONTENT into BRANCH"
    echo ""
    echo "List of available options"
    echo "  -h, --help               Display this help and exit"
    echo "  -v, --version            Display current version"
    echo ""
    echo "Documentation can be found at https://github.com/javanile/lcov.sh"
}

options=$(getopt -n gitlab-knock.sh -o vh -l version,help -- "$@")

eval set -- "${options}"

while true; do
    case "$1" in
        -v|--version) echo "GitLab Knock [0.0.1] - by Francesco Bianco <bianco@javanile.org>"; exit ;;
        -h|--help) usage; exit ;;
        --) shift; break ;;
    esac
    shift
done

##
#
##
error() {
    echo "ERROR --> $1"
    exit 1
}

## curl -fsSL ...
knock_step() {
    curl --request POST \
         --form "branch=$3" \
         --form "commit_message=$4" \
         --form "start_branch=$3" \
         --form "actions[][action]=$1" \
         --form "actions[][file_path]=.gitlab-knock" \
         --form "actions[][content]=$(date)" \
         --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
         -fsSL "${GITLAB_PROJECT_API_URL}/${2//\//%2F}/repository/commits"
}

##
##
knock_process() {
    knock_step update $1 $2 $3 || knock_step create $1 $2 $3
}

##
# Main function
##
main() {
    [[ -z "${GITLAB_PRIVATE_TOKEN}" ]] && error "Missing or empty GITLAB_PRIVATE_TOKEN variable."
    [[ -z "$1" ]] && error "Missing repository identifier"
    [[ -z "$2" ]] && error "Missing repository branch"
    [[ -z "$3" ]] && error "Missing knock message"

    knock_process $1 $2 $3

    echo ""
}

## Entrypoint
main "$@"
