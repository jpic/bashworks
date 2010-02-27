source $HOME/bashworks/module/docs/examples/jpic.bashrc.sh $HOME/bashworks;
module docs;
export docs_path=./example
export docs_template_path=./templates
docs;
perl doc.pl example;
