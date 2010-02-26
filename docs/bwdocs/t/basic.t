use strict;
use warnings;
use Test::More;
use Capture::Tiny qw/capture/;


my ($stdout,$stderr) = capture {


	#need to run these first:
	#
	#source $HOME/src/bashworks-readonly/module/docs/examples/jpic.bashrc.sh $HOME/src/bashworks-readonly
	#module docs
	#export docs_path=/home/perso/pub/bashworks
	#docs

	system("perl doc.pl example");
};

ok($stderr eq ''                    , "stderr is not empty");
ok($stderr !~ /Couldn't open/       , "files could not be opened");
ok($stderr !~ /uninitialized value/ , "unitialized values found");


print "=========\n$stderr\n===========";


