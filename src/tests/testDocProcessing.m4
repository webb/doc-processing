#!/bin/bash

. "CONFIG_LIB_TEST_HELPER"

OPTIND=1
while getopts :vl option
do
    case "$option" in
        v) test_set_verbose;;
        l) test_set_leave_temps;;
        '?') echo "unknown option \"$OPTARG\" in \"${@:$((OPTIND-1)):1}\"" >&2; exit 1;;
        :) echo "no arg to option \"$OPTARG\" in \"${@:$((OPTIND-1)):1}\"" >&2; exit 1;;
        *) echo "unknown error in $0" >&2; exit 1;;
    esac
done

test_mktemp_d TEMPDIR

test_run_verify cp dir1/example1.xml "$TEMPDIR/example1.xml"
cd "$TEMPDIR"

test_run_verify "CONFIG_PREFIX/bin/process-doc" -in example1.xml -makedepend result1.html -out dependencies.mk --temp-dir=.

test_run_verify -1 make -f dependencies.mk result1.html

test_set_stderr <<EOF
file:///$('CONFIG_REALPATH_COMMAND' "$TEMPDIR")/example1.xml / todo: revise to released version of CTAS
EOF

test_run_verify "CONFIG_PREFIX/bin/process-doc" -in example1.xml  -out result1.html 

m4_dnl Local Variables:
m4_dnl mode: shell-script
m4_dnl eval: (sh-set-shell "bash")
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:

