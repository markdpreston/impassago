#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

#usage() { echo "Usage: $0 [prepare|download|check|start|continue|report] <options>" }

source bin/i_download.sh
source bin/i_prepare.sh
source bin/i_check.sh
source bin/i_run.sh
source bin/i_report.sh

case "$1" in
  "download" )
    echo "Download"
    makeDirectories
    getSoftware
    get1000G
    ;;
  "prepare" )
    echo "Prepare"
#    prepare
    ;;
  "check" )
    echo "Check"
#    check
    ;;
  "start" )
    echo "Start"
#    clearData
#    resume    # from start!
    ;;
  "resume" )
    echo "Resume"
#    resume
    ;;
  "report" )
    echo "Report"
#    report
    ;;
  * )
    usage
    ;;
esac


