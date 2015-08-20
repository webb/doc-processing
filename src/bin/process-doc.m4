#!CONFIG_BASH_COMMAND

#HELP:process-doc: convert an XML document format into a rendered document
#HELP:Usage:
#HELP:    process-doc -pdf? -html? -in in-file -out out-file

. "CONFIG_SCRIPT_HELPER"

# default is false
DEBUG=false

run () (
    if test "$DEBUG" = true; then
        for ((i = 1; i <= $#; ++i))
        do if [[ $i != 1 ]]
            then printf ' '
            fi
            printf '"%s"' "${@:$i:1}"
        done
    fi

    exec 3>&1
    while test $# -gt 0; do
        case "$1" in
            -out )
                exec 3 >& "$2"
                if test "$DEBUG" = true; then
                    echo -n '>' "$OUT"
                fi
                shift 2
                ;;
            * ) break ;;
        esac
    done
            
    if test "$DEBUG" = true; then
        echo >&2
    fi

    "$@" >&3
    exec 3>&-
)

InFile=""
OutFile=""
OutType=""
skipBlurbs="false"
# tempDir=""
# tempDirCreated=false

# put everything that needs to be cleaned up here.
goodbye () {
#     if test "$tempDirCreated" = true
#     then
#         assert test "$tempDir" != ""
#         assert test -d "$tempDir"
#         rm -rf "$tempDir"
#     fi
    true
}

trap goodbye 0

#HELP:Options:
#HELP:

#HELP:  --catalog=$catalog.xml | -c $catalog.xml: add an XML catalog for schema validation
CATALOGS=()
opt_catalog () {
    assert test $# = 1
    ensure "Argument to option --catalog must be a file" test -f "$1"
    ensure "Argument to option --catalog must be an xml file" test "$1" != "${1%.xml}"
    CATALOGS+=( "$1" )
}

TEMP_DIR="tmp"
#HELP:    --temp-dir=$dir: set temporary dir to $dir (for dependencies makefile)
opt_temp_dir () {
    assert test $# = 1
    assert test -d "$1"
    TEMP_DIR="$1"
}

#HELP:  --saxon-ee: Use Saxon Enterprise Edition (enables line numbering)
ARG_SAXON_EE=""
ARG_CHECK_DOC_SAXON_EE=""
opt_saxon_ee () {
    assert test $# = 0
    ARG_SAXON_EE="-ee"
    ARG_CHECK_DOC_SAXON_EE="--saxon-ee"
}

while test $# -gt 0
do
    case "$1" in
        --saxon-ee ) 
            opt_saxon_ee
	    shift ;;
        --temp-dir=* ) opt_temp_dir "${1#*=}"
	    shift;;
        --catalog=* ) opt_catalog "${1#*=}"
            shift;;
        -c ) ensure "Option -c requires argument" test $# -ge 2
            opt_catalog "$2"
            shift 2;;
        #HELP:    -d: Debug / Verbose mode
        -d )
            DEBUG=true
            shift
            ;;
        #HELP:    -in in-file.xml : The XML document to render
        -in )
            ensure "parameter -in required argument \$in-file.xml" test $# -ge 2 
            ensure "parameter -in \$in-file.xml must be a file" test -f "$2"
            ensure "parameter -in \$in-file.xml must be readable" test -r "$2"
            InFile="$2"
            InFileDir=$("CONFIG_DIRNAME" "$InFile")
            shift 2
            ;;
        #HELP:    -out out-file : The result file
        -out )
            ensure "parameter -in requires argument \$out-file" test $# -ge 2
            ensure "directory of parameter -out \$out-file out-file must exist" test -d "$("CONFIG_DIRNAME" "$2")"
            OutFile="$2"
            shift 2
            ;;
        #HELP:    -makedepend: produce makefile dependencies 
        -makedepend )
            OutType="mk"
            shift
            ;;
        #HELP:    -skipBlurbs : don't produce dependencies that generate blurb files
        -skipBlurbs )
            skipBlurbs="true"
            shift 1
            ;;
        #HELP:    -pdf : produce results as a PDF file
        -pdf )
            OutType="pdf"
            shift
            ;;
        #HELP:    -html : produce results as an HTML file
        -html )
            OutType="html"
            shift
            ;;
        #HELP:    -text : produce results as a text file, with embedded ^H control codes
        -text )
            OutType="text"
            shift
            ;;
        #HELP:    -plaintext : produce results as a text file, with no ^H control codes
        -plaintext )
            OutType="plaintext"
            shift
            ;;
        #HELP:    -groff : produce results as a GROFF text file
        -groff )
            OutType="groff"
            shift
            ;;
#         #HELP :    -tempdir $dir: use $dir for temporary files
#         #HELP :      (like schematron-derived XSLT files)
#         #HELP :      Otherwise, a temporary directory is created
#         -tempdir )
#             ensure "parameter $1 requires argument \$dir" test $# -ge 2
#             tempDir="$2"
#             ensure "argument \$dir of parameter $1 ($tempDir) must be a directory" test -d "$tempDir"
#             shift 2
#             ;;

        #HELP:    --help : print this help
        -help | --help )
            print_help
            exit 0
            ;;
        * )
            error_exit "Unexpected parameter \"$1\""
            ;;
    esac
done

ensure "parameter -in is required" test "$InFile" != ""
ensure "parameter -out is required" test "$OutFile" != ""
assert test "$InFileDir" != ""
assert test -d "$InFileDir"

# if test "$tempDir" = ""
# then
#     tempDirCreated=true
#     tempDir=$(mktemp -d)
# fi

if test "$OutType" = ""
then
    case "$OutFile" in
        *.pdf ) OutType=pdf ;;
        *.txt ) OutType=text ;;
        *.html ) OutType=html ;;
        *.groff ) OutType=groff ;;
        * ) error_exit "unable to determine output type for out-file" ;;
    esac
fi

assert test "$OutType" = pdf -o "$OutType" = html -o "$OutType" = mk -o "$OutType" = groff -o "$OutType" = text -o "$OutType" = plaintext

#############################################################################
# validate doc.xml against schema

COMMAND=('CONFIG_CHECK_DOC_COMMAND' $ARG_CHECK_DOC_SAXON_EE)
for CATALOG_KEY in "${!CATALOGS[@]}"
do COMMAND+=(--catalog="${CATALOGS[$CATALOG_KEY]}")
done
ensure "input file did not pass doc format check: $InFile" "${COMMAND[@]}" "$InFile"

case "$OutType" in

    plaintext )
        TextFile="$InFileDir/tmp.$(basename "$InFile").txt"
        run rm -f "$TextFile"

        run 'CONFIG_SAXON' $ARG_SAXON_EE -catalog "CONFIG_CATALOG_XML" -opt:0 --readonly -l:on -in "$InFile" -out "$OutFile" -xsl 'CONFIG_DOC_TO_TEXT_XSL'
        ;;

    text )
        GroffFile="$InFileDir/tmp.$(basename "$InFile").groff"
        run rm -f "$GroffFile"

        command=("$0")
        if test "$DEBUG" = true
        then
            command[${#command[@]}]="-d"
        fi
        command=("${command[@]}" -groff -in "$InFile" -out "$GroffFile")

        run "${command[@]}"

        run rm -f "$OutFile"
        ( 
            if test "$DEBUG" = true; then set -o verbose; fi
            groff -t -P-c -Tascii -ms "$GroffFile" \
                | "$BIN"/remove-blank-lines \
                > "$OutFile"
        )
            
        ;;

    groff )
        run rm -f "$OutFile"
        run "$SAXON" -catalog "CONFIG_CATALOG_XML" -opt:0 --readonly -l:on -in "$InFile" -out "$OutFile" -xsl "CONFIG_SHARE_DIR/doc-to-groff.xsl"
        ;;
    
    html )
        
        #############################################################################
        # generate doc.xhtml
        XHTMLFile="$InFileDir/$(CONFIG_BASENAME "$InFile").xhtml"

        run CONFIG_RM -f "$XHTMLFile"
        assert test -f "CONFIG_SHARE_DIR/doc-to-xhtml.xsl"
        run 'CONFIG_SAXON' $ARG_SAXON_EE -catalog 'CONFIG_CATALOG_XML' -opt:0 --readonly -l:on -in "$InFile" -out "$XHTMLFile" -xsl 'CONFIG_SHARE_DIR'/doc-to-xhtml.xsl

        #############################################################################
        # generate doc.html
        HTMLFile="$InFileDir/tmp.$(basename "$InFile").html"

        run rm -f "$HTMLFile"

        run 'CONFIG_SAXON' $ARG_SAXON_EE -opt:0 --readonly -in "$XHTMLFile" -out "$HTMLFile" \
            -xsl 'CONFIG_LIB_XSL_XHTML_TO_HTML'

        #############################################################################
        # put to output file

        run rm -f "$OutFile"
        run cp "$HTMLFile" "$OutFile"

        ;;

    pdf )

        #############################################################################
        # Generate FO file

        FOFile="$InFileDir/tmp.$(basename "$InFile").fo.xml"

        run make -C "$LibDir" doc-to-fo.xsl common.xsl

        run rm -f "$FOFile"
        run "$SAXON" -opt:0 --readonly -l:on -in "$InFile" -out "$FOFile" -xsl "$LibDir"/doc-to-fo.xsl

        assert test -r "$FOFile"

        #############################################################################
        # Generate PDF file

        PDFFile="$InFile/tmp.$(basename "$InFile").pdf"

        run rm -f "$PDFFile"
        run "$SAXON" -opt:0 --readonly -sa -l:on -val:strict -in "$InFile" -out "$FOFile" -xsl "$LibDir"/doc-to-fo.xsl

        run "$IEAD_ROOT"/vendor/fop/tags/fop-1.0-bin/fop-1.0/fop -v -fo "$FOFile" -pdf "$PDFFile"

        assert test -r "$PDFFile"

        #############################################################################
        # copy

        run rm -f "$OutFile"
        run cp "$PDFFile" "$OutFile"

        ;;

    mk )

        run rm -f "$OutFile"

        "CONFIG_XALAN" -L \
            -IN "$InFile" \
            -XSL "CONFIG_DOC_TO_DEPENDENCIES_XSL" \
            -PARAM source-file "$InFile" \
            -PARAM source-dir "$(CONFIG_DIRNAME "$InFile")" \
            > "$OutFile"

        run chmod 400 "$OutFile"

        ;;

    * )
        echo "$(realpath -P "$0"):$LINENO: unexpected file type \"$OutType\"" >&2
        exit 1
        ;;
        
esac
m4_dnl Local Variables:
m4_dnl mode: shell-script
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:
