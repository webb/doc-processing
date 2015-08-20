#!CONFIG_BASH_COMMAND

. "CONFIG_SCRIPT_HELPER"

#HELP:check-doc - Validate an XML file as being a valid specification doc
#HELP:Options:

#HELP:  --help | -h: Print this help
opt_help () {
    assert test $# = 0
    print_help
    exit 0
}

#HELP:  --catalog=$catalog.xml | -c $catalog.xml: add an XML catalog for schema validation
CATALOGS=()
opt_catalog () {
    assert test $# = 1
    ensure "Argument to option --catalog must be a file" test -f "$1"
    ensure "Argument to option --catalog must be an xml file" test "$1" != "${1%.xml}"
    CATALOGS+=( "$1" )
}

#HELP:  --saxon-ee: Use Saxon Enterprise Edition (enables line numbering)
ARG_SAXON_EE=""
opt_saxon_ee () {
    assert test $# = 0
    ARG_SAXON_EE="-ee"
}

#HELP:  -t $dir: use given temporary directory
unset TEMP_DIR
opt_temp_dir () {
    assert test $# = 1
    ensure "temp dir option must be a directory" test -d "$1"
    TEMP_DIR="$1"
}

#HELP:  -v: be verbose

OPTIND=1
while getopts :-:c:hvt: option
do
    case "$option" in
        c ) opt_catalog "$OPTARG";;
        h ) opt_help;;
        t ) opt_temp_dir "$OPTARG";;
        v ) script_helper_set_verbose;;
        - )
            case "$OPTARG" in
                help ) opt_help;;
                saxon-ee ) opt_saxon_ee;;
                catalog=* ) opt_catalog "${OPTARG#*=}";;
                * ) fail "unknown long option or bad long option argument: \"$OPTARG\"";;
            esac
            ;;
        '?' ) fail "unknown option \"$OPTARG\"";;
        : ) fail "option \"$OPTARG\" missing argument";;
        * ) assert false;;
    esac
done
shift $((OPTIND - 1))

ensure "check-doc needs at least one argument to validate" test $# -ge 1

if test is-set != "${TEMP_DIR:+is-set}"
then TEMP_DIR=$(mktemp -d)
fi

debug_echo "# temporary directory = \"$TEMP_DIR\""

ERROR_LEVEL=0

while test $# -gt 0
do
    debug_echo "# $1"
    if ! "CONFIG_CHECK_XML" "$1"
    then echo "File did not pass XML check: $1" >&2
        ERROR_LEVEL=1
        break
    fi
    XSDVALID_COMMAND=('CONFIG_XSDVALID')
    for CATALOG_KEY in "${!CATALOGS[@]}"
    do XSDVALID_COMMAND+=( -catalog "${CATALOGS[$CATALOG_KEY]}" )
    done
    XSDVALID_COMMAND+=( -catalog 'CONFIG_CATALOG_XML' )
    if ! "${XSDVALID_COMMAND[@]}" "$1"
    then echo "File did not pass doc XML Schema check: $1" >&2
        ERROR_LEVEL=1
        break
    fi
    "CONFIG_INSTALL" --compare --no-target-directory "CONFIG_DOC_SCH" "$TEMP_DIR"/doc.sch
    if ! 'CONFIG_SCHEMATRON' $ARG_SAXON_EE -catalog "CONFIG_CATALOG_XML" -schema "$TEMP_DIR"/doc.sch "$1"
    then echo "File did not pass doc Schematron check: $1" >&2
        break
    fi
    shift
done

exit "$ERROR_LEVEL"

m4_dnl Local Variables:
m4_dnl mode: shell-script
m4_dnl eval: (sh-set-shell "bash")
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:

