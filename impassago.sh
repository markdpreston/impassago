#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

usage() { echo "Usage: $0 [download|check|filter|impute|gwas|permute|pathways|report] <options>"; exit; }
if [ -z "${1:-}" ]; then usage; fi

source bin/i_download.sh
source bin/i_check.sh
source bin/i_filter.sh
source bin/i_impute.sh
source bin/i_report.sh

case "$1" in
  "download" )
    echo "Download"
    makeDirectories
    getSoftware
    get1000G
    ;;
  "check" )
    echo "Check"
    checkAll
    ;;
  "filter" )
    echo "filter"
    filter
    ;;
  "impute" )
    echo "impute"
    impute
    ;;
  "start" )
    echo "start"
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


