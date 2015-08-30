# -*-autoconf-*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([doc-processing], [0], [wr@gatech.edu])
AC_COPYRIGHT

test "x$prefix" != "xNONE" || AC_MSG_ERROR([prefix must be set])

# Checks for programs.
AC_PROG_INSTALL
AC_PROG_MKDIR_P
AC_PROG_SED
AC_PROG_AWK

dnl WR_subst_prog( $command-name )
dnl   e.g., WR_subst_prog(bash) will set @bash@
AC_DEFUN([WR_subst_prog],[AC_PATH_PROG($1,$1)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

dnl WR_subst_prog_options( $command-short-name, $command-name-options ... )
dnl   e.g., WR_subst_prog_options(cat, gcat cat) will set @cat@
AC_DEFUN([WR_subst_prog_options],[AC_PATH_PROGS($1,$2)
  test "x$[]$1" = "x" && AC_MSG_ERROR([$1 not found])])dnl

WR_subst_prog(bash)

WR_subst_prog_options(chmod, gchmod chmod)
WR_subst_prog_options(m4, gm4 m4)

AC_PATH_PROG(check_simple_xsd,check-simple-xsd)

AC_PATH_PROGS(stow,stow,stow)

#############################################################################
# prerequisites

WR_subst_prog(saxon)

dnl WR_subst_file( $file-path-name )
dnl   fail if a file is not found; remember the relative path
AC_DEFUN([WR_subst_prefix_file],[
  AC_SUBST($1,$2)
  AC_CHECK_FILE(${prefix}/$2,,[AC_MSG_ERROR([file ${prefix}/$2 not found])])
])

WR_subst_prefix_file(opt_help_bash,share/wrtools-core/opt_help.bash)
WR_subst_prefix_file(opt_verbose_bash,share/wrtools-core/opt_verbose.bash)
WR_subst_prefix_file(fail_bash,share/wrtools-core/fail.bash)
WR_subst_prefix_file(paranoia_bash,share/wrtools-core/paranoia.bash)
WR_subst_prefix_file(temp_bash,share/wrtools-core/temp.bash)

WR_subst_prog_options(check_xml,check-xml)
WR_subst_prog(xalan)
WR_subst_prog(xsdvalid)
WR_subst_prog(install)
WR_subst_prog(schematron)

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile], [chmod 444 Makefile])
AC_CONFIG_FILES([stow.mk], [chmod 444 stow.mk])
AC_OUTPUT
