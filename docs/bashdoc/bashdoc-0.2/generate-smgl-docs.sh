#!/bin/bash

#
# This script will generate bash documentation (for as far as it has been made
# available in the code) from all Source Mage libs and commands.
#
BIN=/usr/bin
DOCDIR=/usr/doc/sourcemage-docs
BASHDOC=$BIN/bashdoc.sh
FLOW=$BIN/flow.sh
SRC2HTML=$BIN/src2html.sh
PROJECT=SourceMageDocs

QUIET=${QUIET:--q -q}

SCRIPTS="/var/lib/sorcery/modules/lib* /var/lib/sorcery/modules/url_handlers/url_* \
/var/lib/sorcery/modules/build_api/* /var/lib/sorcery/modules/dl_handlers/dl_* \
/usr/sbin/cast /usr/sbin/sorcery /usr/sbin/dispel /usr/sbin/gaze /usr/sbin/invoke \
/usr/sbin/cleanse /usr/sbin/confmeld /usr/sbin/alter /usr/sbin/delve /usr/sbin/cabal \
/usr/sbin/scribbler /usr/sbin/scribe /usr/sbin/summon /usr/sbin/vcast /usr/sbin/xsorcery"
#exclude non-sorcery files, like backups~ or numbered versions
for FILE in $SCRIPTS
do
	if grep -q "[0-9]" <<< $FILE; then
		if grep -Eq "(libgcc2|api[12])" <<< $FILE; then
			SCRIPTS2="$SCRIPTS2 $FILE"
		fi
	elif grep -q '~' <<< $FILE; then
		true
	else
		SCRIPTS2="$SCRIPTS2 $FILE"
	fi
done
SCRIPTS="$SCRIPTS2"

# make the bashdoc dir
if [ -d $DOCDIR ] ; then
	rm -rf $DOCDIR
	mkdir -p $DOCDIR
else
	mkdir -p $DOCDIR
fi

# generate docs for libs
if [  -x  "$BASHDOC"  ] ; then
	$BASHDOC ${QUIET} -p $PROJECT -o $DOCDIR $SCRIPTS
else
	echo "The bashdoc tools are not installed, please cast bashdoc!"
fi

${SRC2HTML} --funcs $DOCDIR $SCRIPTS
if which dot >/dev/null 2>&1 ; then
	${FLOW}	--funcs $DOCDIR --exclude debug --exclude message \
		--exclude query $SCRIPTS
else
	echo "No graphviz found, not generating images."
fi

# end
