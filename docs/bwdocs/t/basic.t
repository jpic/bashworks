use strict;
use warnings;
use Test::More;
use Capture::Tiny qw/capture/;


my ($stdout,$stderr) = capture {
	system("perl doc.pl example");
};

ok($stderr eq ''                    , "stderr is not empty");
ok($stderr !~ /Couldn't open/       , "files could not be opened");
ok($stderr !~ /uninitialized value/ , "unitialized values found");


print "=========\n$stderr\n===========";


