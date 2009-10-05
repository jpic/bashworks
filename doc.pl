#!/usr/bin/perl

use Cwd 'realpath';

my %module_paths = ();
my %processed_scripts = ();
my %func_lines = ();
my %func_files = ();
my %func_modules = ();
my %func_doc = ();
my %file_doc = ();

# find modules and submodules
my @sources = split(/\n/, `find . -name source.sh`);
foreach(@sources) {
    s/\/source\.sh//;
    $path = realpath($_);
    s/\.\///;
    s/\//_/;
    $module_paths{$_} = $path;
}

# find scripts and their belonging module
# longest module name first
foreach $module (reverse sort { length($module_paths{$a}) cmp length($module_paths{$b}) } keys %module_paths) {
    # print $module, "\n";
    
    $path = $module_paths{$module};
    @scripts = split(/\n/, `find "$path" -name "*.sh"`);

    foreach(@scripts) {
        $script = $_;
        if(grep($_ eq $script, keys %processed_scripts)) {
            next;
        }

        $processed_scripts{$_} = $module;

        #print "  ", $_, "\n";
    }    
}

# find docblocks and their belonging functions
foreach $script (keys %processed_scripts) {
    $module = $processed_scripts{$script};

    open SCRIPT, "<$script";

    $line= 1;
    $current_doc = "";
    $current_func = "";
    while(<SCRIPT>) {
        if (/^#-/) {
            $file_doc{$script} = $current_doc;
            $current_func = "";
        } elsif (/^#/) {
            # function current_docblock
            $current_doc .= $_;
        } elsif (/^function ([^ (]*)/) {
            # function declaration
            $current_func = $1;
            $func_lines{$current_func} = $line;
            $func_files{$current_func} = $script;
            $func_modules{$current_func} = $module;
        } elsif (/}/) {
            # function end, do clean
            $func_doc{$current_func} = $current_doc;
            $current_doc = "";
            $current_func = "";
        }
        
        $line++;
    }
}

print "$func_doc{conf}"
