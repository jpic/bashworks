#!/bin/bash
#set -x
VERSION="0.0.1"

#------------------
##	Creates a dia graph of the functional "uses" relationships
##	Uses the .func files created by bashdoc.
## @Gloabals FUNC_DIR, SCRIPTS
#------------------
function Args()
{
	while [ $# -gt 0 ] ; do
		case $1 in 
			--funcs)	FUNC_DIR=${2%/}
					shift 2
					;;
			--exclude)	EXCLUDE="$EXCLUDE $2"
					shift 2
					;;
			-*)		Usage
					exit 1
					;;
			*)		SCRIPTS="$*"
					break
					;;
		esac
	done
}

#---------------
##	Usage for this script
#---------------
function Usage()
{
cat << EOF
$(basename $0) --funcs func_directory [--exclude function] script [script...]
	'--funcs func_directory'	Directory which contains the *.func files
	'--exclude function'		Functions to not include as a destination
	script	A script wich has a .func file
	
	Example: flow.sh --funcs docs /home/user/p4/sgl/devel/sorcery/var/lib/sorcery/modules/lib{misc,codex} bash2doc.sh
EOF
}

function TranslateSource()
{
	local src=$1
	local currFunc=""
	local funcText=""
	local LINE
	shift
	local funcFiles="$*"
	
	while read LINE ; do
#echo "($currFunc)[$LINE]" >&2	
		#Cut off comments
		LINE=${LINE%%#*}
		#Ignore blank lines
		[ "$LINE" ] || continue
		
		if ! [ "${LINE#function}" == "$LINE" ] ; then
			[[ $funcText ]] && ParseFunction "$currFunc" "$funcText" "$funcFiles"
			funcText=""
			currFunc=${LINE#function}
			currFunc=${currFunc%%()*}
			currFunc=${currFunc// /}
			echo -e "\tFunction ($currFunc)..." >&2
		elif [[ $currFunc ]] ; then
			if [[ $funcText ]] ; then
				funcText="$funcText"$'\n'"$LINE"
			else
				funcText="$LINE"
			fi
		fi
	done < $src
	[[ $funcText ]] && ParseFunction "$currFunc" "$funcText"  "$funcFiles"
}

function ParseFunction()
{
#echo "Function ($1)" >&2
#echo "$2" >&2
	local allWords=$( echo "$2" | SedWords | tr -s '[[:blank:]]' '\n' | sort -b -u )
#echo "Found all words" >&2
	local importantWords=$( cat $3 | tr -s '[[:blank:]]' '\n' | sed '/^$/d' | sort )
	local dupeImportantWords=$( echo "$importantWords" | uniq -d )
	[[ $dupeImportantWord ]] && echo "Warning, duplicate functions: $dupeImportantWords"
	importantWords=$( echo "$importantWords" | uniq )
	
	echo "$importantWords"$'\n'"$allWords" | tr -d '\t ' | sort | uniq -d | \
		sed -e "s/^/		$1 -> /" 

}

function MakeSedExpression()
{
	local orig="$1"
	shift
	for f in $(cat $*) ; do
		echo "" "-e" '"s@\([^[:alnum:]_-]\)'$f'\([^[:alnum:]_-]\)@'$orig' -> '$f'@pg"'
		echo "" "-e" '"s@^'$f'\([^[:alnum:]_-]\)@'$orig' -> '$f'@pg"'
		echo "" "-e" '"s@\([^[:alnum:]_-]\)'$f'\$@\'$orig' -> '$f'@pg"'
		echo "" "-e" '"s@^'$f'\$@'$orig' -> '$f'@pg"'
	done
}

function SedWords()
{
	sed -n	-e 's@[^[:alnum:]_-]\([[:alnum:]_-]*\)[^[:alnum:]_-]@ \1 @pg'	\
			-e 's@^\([[:alnum:]_-]*\)[^[:alnum:]_-]@\1 @pg'				\
			-e 's@[^[:alnum:]_-]\([[:alnum:]_-]*\)\$@ \1@pg'				\
			-e 's@^\([[:alnum:]_-]*\)\$@\1@pg'
}

Args "$@"
FUNC_FILES="$FUNC_DIR/*.funcs"
OUT="out.dot"

echo "digraph Sorcery {" > $OUT
for i in $SCRIPTS ; do
	echo "$i:" >&2
	htmlFile=${i//\//.}
	htmlFile="${htmlFile#.}.html"
	echo "	subgraph ${i##*/} {" >> $OUT

	#Awk removes self-loops
	TranslateSource $i $FUNC_FILES | sort | uniq | \
		awk '{ if($1 != $3) { printf("%s [URL=\"'$htmlFile'#%s\"]\n", $0, $1); } }' >>$OUT
	echo "	}" >> $OUT
done 
echo "}" >> $OUT

echo "Excluding $EXCLUDE" >&2
GREP_EXPR=""
for i in $EXCLUDE ; do
	if [[ $GREP_EXPR ]] ; then
		GREP_EXPR="$GREP_EXPR|$i"
	else
		GREP_EXPR=$i
	fi
done

if [[ $GREP_EXPR ]] ; then
	grep -v -E -e "-> ($GREP_EXPR)" $OUT > $OUT.tmp
	mv $OUT.tmp $OUT
fi

echo "Rendering..." >&2
dot $OUT -o $OUT.dot
dot -Tcmap -o $OUT.cmap $OUT.dot
dot -Tpng -o $OUT.png $OUT.dot

echo "Creating HTML..." >&2
echo "<html><body><MAP NAME=map>" > $OUT.html
cat $OUT.cmap >> $OUT.html
echo "</MAP><IMG SRC=$OUT.png ISMAP USEMAP=\"#map\">" >> $OUT.html
echo "<!-- Created with version $VERSION of flow.sh, on $(date). -->" >>$OUT.html
echo "</body></html>" >> $OUT.html

mv $OUT $OUT.cmap $OUT.png $OUT.dot $OUT.html $FUNC_DIR
echo "Done." >&2



