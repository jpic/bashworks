#!/usr/local/bin/bash
echo $BASH_VERSION > /tmp/ver_
source $HOME/bashworks/module/docs/examples/jpic.bashrc.sh $HOME/bashworks;
module docs;
export docs_path=./example
rm $docs_path/*.html
export docs_template_path=./templates
docs;
perl doc.pl example;
