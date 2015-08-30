#!/usr/bin/env bash

root_dir=$(dirname "$0")/..
. "$root_dir"/MACRO_OPT_HELP_BASH
. "$root_dir"/MACRO_OPT_VERBOSE_BASH
. "$root_dir"/MACRO_FAIL_BASH
. "$root_dir"/MACRO_PARANOIA_BASH
. "$root_dir"/MACRO_TEMP_BASH


#HELP:COMMAND_NAME: Validate a file as being a valid doc
#HELP:Options:

#HELP:  --help | -h: Print this help
#HELP:  --verbose, -v: Print additional diagnostics
#HELP:  --not-paranoid: Omit basic/foundational validations

#HELP:  --catalog=$xml-catalog.xml | -c $xml-catalog.xml: add an XML catalog for schema validation
CATALOGS=()
opt_catalog () {
    [[ $# = 1 ]] || fail_assert "$FUNCNAME expected 1 arg, got $#"
    check-xml "$1" || fail "check-xml failed on file $1"
    CATALOGS+=( "$1" )
}

OPTIND=1
while getopts :c:hv-: option
do
    case "$option" in
        c ) opt_catalog "$OPTARG";;
        h ) opt_help;;
        v ) opt_verbose;;
        - )
            case "$OPTARG" in
                catalog=* ) opt_catalog "${OPTARG#*=}";;
                help ) opt_help;;
                verbose ) opt_verbose;;
                not-paranoid ) opt_not_paranoid;;
                catalog ) fail "Long option $OPTARG is missing its required argment";;
                help=* | not-paranoid=* )
                    fail "Long option \"${OPTARG%%=*}\" has an unexpected argument";;
                * ) fail "Unknown long option \"${OPTARG%%=*}\"";;
            esac
            ;;
        '?' ) fail "unknown option \"$OPTARG\"";;
        : ) fail "option \"$OPTARG\" missing argument";;
        * ) assert false;;
    esac
done
shift $((OPTIND - 1))

if (( $# == 0 ))
then warn "not doing anything because no files were listed"
     exit 0
fi

share_dir=$root_dir/'MACRO_SHARE_DIR_REL'
! is_paranoid || [[ -d $share_dir ]] || fail "share directory not found: $share_dir"

temp_make_dir working_dir

error_level=0
while test $# -gt 0
do
    if is_paranoid && ! vrun check-xml "$1"
    then printf "File did not pass XML check: %s" "$1" >&2
        error_level=1
        break
    fi
    XSDVALID_COMMAND=( xsdvalid )
    for CATALOG_KEY in "${!CATALOGS[@]}"
    do XSDVALID_COMMAND+=( -catalog "${CATALOGS[$CATALOG_KEY]}" )
    done
    XSDVALID_COMMAND+=( -catalog "$share_dir"/xml-catalog.xml )
    if ! vrun "${XSDVALID_COMMAND[@]}" "$1"
    then printf "File did not pass doc XML Schema check: $1" >&2
        error_level=1
        break
    fi
    if [[ ! -f $working_dir/doc.sch ]]
    then vrun install  --compare --no-target-directory "$share_dir"/doc.sch "$working_dir"/doc.sch
    fi
    if ! vrun schematron --schema="$working_dir"/doc.sch --format=text "$1"
    then printf "File did not pass doc Schematron check: %s" "$1" >&2
         error_level=1
         break
    fi
    shift
done

exit "$error_level"

m4_dnl Local Variables:
m4_dnl mode: shell-script
m4_dnl eval: (sh-set-shell "bash")
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:

