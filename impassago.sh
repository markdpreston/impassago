#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

#usage() { echo "Usage: $0 [prepare|download|check|start|continue|report] <options>" }

case "$1" in
  "prepare" )
    echo "Prepare"
    bin/i_prepare.sh
    ;;
  "download" )
    echo "Download"
    bin/i_download.sh
    ;;
  "check" )
    echo "Check"
    bin/i_check.sh
    ;;
  "start" )
    echo "Start"
    ;;
  "resume" )
    echo "Resume"
    bin/i_run.sh
    ;;
  "report" )
    echo "Resume"
    bin/i_report.sh
    ;;
  * )
    usage
    ;;
esac


