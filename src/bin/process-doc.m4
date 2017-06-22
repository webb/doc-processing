#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

root_dir=$(dirname "$0")/..
. "$root_dir"/MACRO_OPT_HELP_BASH
. "$root_dir"/MACRO_OPT_VERBOSE_BASH
. "$root_dir"/MACRO_FAIL_BASH
. "$root_dir"/MACRO_PARANOIA_BASH
. "$root_dir"/MACRO_TEMP_BASH

#HELP:COMMAND_NAME: convert an XML document format into a rendered document
#HELP:Usage:
#HELP:    COMMAND_NAME $options* --in-file=$file.xml --out-file=$file
#HELP:Options:
#HELP:  --help | -h: Print this help
#HELP:  --keep-temps | -k: Don't delete temporary files
#HELP:  --not-paranoid: Omit basic/foundational validations
#HELP:  --verbose, -v: Print additional diagnostics

#HELP:  --catalog=$catalog.xml | -c $catalog.xml: add an XML catalog for schema
#HELP:      validation of embedded XML content of the document
catalog_files=()
opt_catalog () {
    (( $# == 1 )) || fail_assert "$FUNCNAME expected 1 args, got $#"
    catalog_files+=( "$1" )
}

#HELP:  --in=$file, -i $file: Take source input from file
unset in_file
opt_in () {
    (( $# == 1 )) || fail_assert "$FUNCNAME takes 1 arg (got $#)"
    check-xml "$1" || fail "Argument to option --in is not an XML file: $1"
    in_file=$1
}

#HELP:  --out=$file, -o $file: Write output to file
unset out_file
opt_out () {
    (( $# == 1 )) || fail_assert "$FUNCNAME takes 1 arg (got $#)"
    [[ -d "$(dirname "$1")" ]] || fail "Directory of argument to --out must exist: $(dirname "$1")"
    out_file=$1
}

#HELP:  --format=$format | -f $format: set format of output file
#HELP:      Default format is html
out_format=html
#HELP:      formats: html: rendered HTML output
#HELP:               text: diff-quality text output
#HELP:               makedepend: Makefile dependencies
#HELP:               rules-id-map: XML file mapping rule numbers to descriptive IDs
opt_format () {
    [[ $# = 1 ]] || fail_assert "$FUNCNAME expected 1 args, got $#"
    case "$1" in
        html | text | makedepend | rules-id-map ) out_format="$1";;
        * ) fail "Unexpected format \"$1\"; expected html or text";;
    esac
}

OPTIND=1
while getopts :c:f:hi:ko:v-: option
do
    case "$option" in
        c ) opt_catalog "$OPTARG";;
        f ) opt_format "$OPTARG";;
        h ) opt_help;;
        i ) opt_in "$OPTARG";;
        k ) opt_keep_temps;;
        o ) opt_out "$OPTARG";;
        v ) opt_verbose;;
        - ) case "$OPTARG" in
                catalog=* ) opt_catalog "${OPTARG#*=}";;
                format=* ) opt_format "${OPTARG#*=}";;
                help ) opt_help;;
                in=* ) opt_in "${OPTARG#*=}";;
                keep-temps ) opt_keep_temps;;
                not-paranoid ) opt_not_paranoid;;
                out=* ) opt_out "${OPTARG#*=}";;
                verbose ) opt_verbose;;
                help=* | keep-temps=* | verbose=* | opt_not_paranoid=* )
                    fail "Long option \"${OPTARG%%=*}\" has unexpected argument";;
                catalog | format | in | out )
                    fail "Long option \"$OPTARG\" is missing required argument";;
                * ) fail "Unknown long option \"${OPTARG%%=*}\"";;
            esac;;
        '?' ) fail "Unknown short option \"$OPTARG\"";;
        : ) fail "Short option \"$OPTARG\" missing argument";;
        * ) fail_assert "Bad state in getopts (OPTARG=\"$OPTARG\")";;
    esac
done
shift $((OPTIND-1))

[[ is-set = ${in_file+is-set} ]] || fail "Option --in is required"
[[ is-set = ${out_file+is-set} ]] || fail "Option --out is required"

share_dir=${root_dir}/'MACRO_SHARE_DIR_REL'
! is_paranoid || [[ -d $share_dir ]] || fail_assert "share directory not found: $share_dir"

if is_paranoid
then command=(check-doc)
     for CATALOG_KEY in "${!catalog_files[@]}"
     do command+=(--catalog="${catalog_files[$CATALOG_KEY]}")
     done
     command+=( "$in_file" )
     vrun "${command[@]}" || fail "input file failed check-doc: $in_file"
fi

case $out_format in
    text )
        vrun saxon --in="$in_file" \
             --out="$out_file" \
             --xsl="$share_dir"/doc-to-text.xsl ;;
    rules-id-map )
        vrun saxon --in="$in_file" \
             --out="$out_file" \
             --xsl="$share_dir"/get-rules-id-map.xsl ;;
    html )
        temp_make_dir working_dir
        xhtml_file=$working_dir/$(basename "$in_file").xhtml
        
        vrun saxon --xsl="$share_dir"/doc-to-xhtml.xsl \
             --in="$in_file" \
             --out="$xhtml_file"
        vrun saxon --in="$xhtml_file" \
             --out="$out_file" \
             --xsl="$share_dir"/xhtml-to-html4.01.xsl ;;
    makedepend )
        xalan --in="$in_file" \
              --xsl="$share_dir"/doc-to-dependencies.xsl \
              --param=source-file="$in_file" \
              --param=source-dir="$(dirname "$in_file")" \
              --out="$out_file" -- -L;;
    * ) fail_assert "unknown output format: $out_format";;
esac
m4_dnl Local Variables:
m4_dnl mode: shell-script
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:
