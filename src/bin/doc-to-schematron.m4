#!CONFIG_BASH_COMMAND

#HELP:doc-to-schematron: generate a Schematron document from a doc
#HELP:Usage:
#HELP:    doc-to-schematron options* file.doc
#HELP:Options:

. 'CONFIG_SCRIPT_HELPER'

#HELP:    --help | -h: print this help
opt_help () {
    print_help
    exit 0
}

#HELP:    --out=$file | -o $file: send output to Schematron file $file
unset out_path
opt_out () {
    (( $# == 1 )) || fail "opt_out() must have 1 arg (got $#)"
    out_path=$1
}

#HELP:    --blurb-set=$id | -b $id: use blurb set id $id
unset blurb_set_id
opt_blurb_set () {
    (( $# == 1 )) || fail "opt_blurb_set() must have 1 arg (got $#)"
    blurb_set_id=$1
}

#HELP:    --title=$title | -t $title: give Schematron document the identified title
unset title
opt_title () {
    (( $# == 1 )) || fail "opt_title() must have 1 arg (got $#)"
    title=$1
}

OPTIND=1
while getopts :hp:-: option
do case "$option" in
       b ) opt_blurb_set "$OPTARG";;
       h ) opt_help;;
       o ) opt_out "$OPTARG";;
       t ) opt_title "$OPTARG";;
       - ) case "$OPTARG" in
               help ) opt_help;;
               out=* ) opt_out "${OPTARG#*=}";;
               blurb-set=* ) opt_blurb_set "${OPTARG#*=}";;
               title=* ) opt_title "${OPTARG#*=}";;
               out | blurb-set | title ) fail "Argument required for long option \"$OPTARG\"";;
               help=* ) fail "No argument expected for long option \"${OPTARG%%=*}\"";;
               * ) fail "Unknown long option \"$OPTARG\"";;
           esac;;
       '?' ) fail "Unknown short option \"$OPTARG\"";;
       : ) fail "Short option \"$OPTARG\" missing argument";;
       * ) fail "Bad state in getopts (OPTARG=\"$OPTARG\")";;
   esac
done
shift $((OPTIND-1))      

[[ ${out_path+is-set} = is-set ]] || fail "option --out=$file is required"
[[ $# = 1 ]] || fail "Must have 1 remaining argument: doc file to convert to Schematron"
[[ -f "$1" ]] || fail "argument must be file: $1"
[[ -r "$1" ]] || fail "argument must be readable: $1"

'CONFIG_SAXON' -l:on -in "$1" -out "$out_path" -xsl 'CONFIG_DOC_TO_SCHEMATRON_XSL' - blurb-set="$blurb_set_id" title="$title"

