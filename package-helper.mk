
# PACKAGE_HELPER_PREPROCESS: expand configuration macros in source files
# usage: $(call PACKAGE_HELPER_PREPROCESS, $source, $dest, $macros)
#   where $source is the source file
#   and $dest is the dest file
#   and $macros is a file that contains the M4 -P macros output by configure
# example: $(call PACKAGE_HELPER_PREPROCESS,$<,$@,config-decls.m4)
PACKAGE_HELPER_PREPROCESS = \
	rm -f $(2); \
	mkdir -p $(dir $(2)); \
	m4 -P $(3) $(1) > $(2); \
	chmod $(shell stat --format="%a" $(1)) $(2); \
	chmod uog-w $(2)

# PACKAGE_HELPER_COPY: copy file, preserving permissions
# usage: $(call PACKAGE_HELPER_COPY, $source, $dest)
#   where $source is the source file
#   and $dest is the dest file
# example: $(call PACKAGE_HELPER_COPY,$<,$@)
PACKAGE_HELPER_COPY = \
	srcPerms=$$(stat --format=%a $(1)); \
	destPerms=$$(awk 'BEGIN { printf "%3o", and(0'"$$srcPerms"',compl(0222)); }'); \
	install -T -D --mode=$$destPerms $(1) $(2)

# PACKAGE_HELPER_INSTALL: install the image tree as a STOW package
# usage $(call PACKAGE_HELPER_INSTALL,$packages-root,$package-name)
#    where PACKAGES_ROOT is the packages/ dir within a stow tree
#    and PACKAGE_NAME is the name of the installed destination package
# example $(call PACKAGE_HELPER_INSTALL,$(PACKAGES_DIR),$(PACKAGE_NAME))
PACKAGE_HELPER_INSTALL = \
	if test -d $(1)/$(2); then \
	 	stow -d $(1) --delete $(2) ; \
	fi; \
	mkdir -p $(1); \
	chmod u+w $(1); \
	if test -d $(1)/$(2); then \
		find $(1)/$(2) -type d -exec chmod u+w {} \; ; \
	fi ; \
	rsync --perms --chmod=uog-w -v --delete -a --exclude='*~' image/ $(1)/$(2)/ ; \
	stow -d $(1) $(2) ; \
	find $(1)/$(2) -type d -exec chmod uog-w {} \; ; \
	chmod uog-w $(1)

# PACKAGE_HELPER_UNINSTALL: uninstall the image tree from STOW
# usage $(call PACKAGE_HELPER_UNINSTALL,$packages-root,$package-name)
#    where PACKAGES_ROOT is the packages/ dir within a stow tree
#    and PACKAGE_NAME is the name of the installed destination package
# example $(call PACKAGE_HELPER_UNINSTALL,$(PACKAGES_DIR),$(PACKAGE_NAME))
PACKAGE_HELPER_UNINSTALL = \
	if test -d $(1)/$(2); then \
	    stow -d $(1) --delete $(2); \
	    chmod u+w $(1); \
	    find $(1)/$(2) -type d -exec chmod u+w {} \; ; \
	    rm -rf $(1)/$(2); \
	    chmod uog-w $(1); \
	fi

