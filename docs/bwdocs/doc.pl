#!/usr/bin/perl

use Text::Template;
use Cwd 'realpath';
use Text::Template 'fill_in_file';

my $template_dir = $ENV{"docs_template_path"};
print "Templates dir (env \$docs_template_path): $template_dir\n";

my $out_dir = $ENV{"docs_path"};
print "Documentation output (env \$docs_path): $out_dir\n";

my $debug = $ENV{"docs_debug"} || 0;
print "Debug (env \$docs_debug): $debug\n";

my $tpldebug = $ENV{"docs_template_debug"} || 0;
print "Template debug (env \$docs_template_debug): $tpldebug\n";

my %module_paths = ();
my %file_module = ();
my %file_doc = ();
my %file_relative = ();
my %func_lines = ();
my %func_files = ();
my %func_modules = ();
my %func_doc = ();
my %func_link = ();

foreach $argnum (0 .. $#ARGV) {
    # find modules and submodules
    @sources = split(/\n/, `find $ARGV[$argnum] -name source.sh`);
    foreach(@sources) {
        s/\/source\.sh//;
        $path = realpath($_);
        s/($ARGV[$argnum])\///;
        s/\//_/;
        $module_paths{$_} = $path;
    }
}

if ( $debug ) {
    print "Phase 1: finding modules (_pre_source)\n";
}

# find scripts and their belonging module
# longest module name first
foreach $module (reverse sort { length($module_paths{$a}) cmp length($module_paths{$b}) } keys %module_paths) {

    $path = $module_paths{$module};
    
    if ( $debug ) {
        print "- $module from $path:\n";
    }

    @scripts = split(/\n/, `find "$path" -name "*.sh"`);

    foreach(@scripts) {
        $script = $_;
        if(grep($_ eq $script, keys %file_module)) {
            next;
        }

        if(/bashunit/ || /shunit/) {
            if ( $module !~ /^mtests_/ ) {
                next;
            }
        }

        $file_module{$_} = $module;
        $absolute = $_;

        $_ = $module;
        s/_/\//g;
        $module_rel = $_;

        $_ = $absolute;
        s/^.*($module_rel)/$module_rel/;
        $file_relative{$absolute} = $_;

    
        if ( $debug ) {
            print "  absolute path: $absolute\n  relative path: $_\n";
        }
    }    
}

if ( $debug ) {
    print "Phase 2: analysing modules (source)\n";
}

# find docblocks and their belonging functions
foreach $script (keys %file_module) {
    $module = $file_module{$script};

    if ( $debug ) {
        print "- $module";
    }

    open SCRIPT, "< $script";

    $line= 1;
    $current_doc = "";
    $current_func = "";
    $script_doc = "";
    while(<SCRIPT>) {
        if (/^# / || /^##/) {
            # function current_docblock
            $current_doc .= $_;
        } elsif (/^\n$/ and $current_doc and $script_doc eq "") {
            # script doc end
            $file_doc{$script} = $current_doc;
            $script_doc = $current_doc;
            $current_doc = "";
        } elsif (/^function ([^ (]*)/) {
            # function declaration
            $current_func = $1;
            $func_lines{$current_func} = $line;
            $func_files{$current_func} = $script;
            $func_modules{$current_func} = $module;
            $func_link{$current_func} = $module . ".html#" .$current_func;
        } elsif (/mlog ([^ ]+) ['"]([^'"]+)['"]/) {
            $current_doc .= "# \@log $1 $2\n"
        } elsif (/^}/) {
            # function end, do clean
            $func_doc{$current_func} = $current_doc;
            $current_doc = "";
            $current_func = "";
        }
        
        $line++;
    }

    close SCRIPT;

    if ( $debug ) {
        print "  done reading $script";
    }
}

if ( $debug ) {
    print "Phase 3: rendering\n";
}

for $module ( keys %module_paths ) {
    if ( $debug ) {
        print "- $module:\n";
    }

    $template = Text::Template->new(TYPE => 'FILE',  SOURCE => $template_dir . '/module_index.html')
      or die "Couldn't construct template: $Text::Template::ERROR";

    $text = $template->fill_in( HASH => {
        "module_name" => \$module,
        "template_dir" => \$template_dir,
        "out_dir" => \$out_dir,
        "debug" => \$debug,
        "tpldebug" => \$tpldebug,
        "module_paths" => \%module_paths,
        "file_module" => \%file_module,
        "file_doc" => \%file_doc,
        "file_relative" => \%file_relative,
        "func_lines" => \%func_lines,
        "func_link" => \%func_link,
        "func_files" => \%func_files,
        "func_modules" => \%func_modules,
        "func_doc" => \%func_doc,
    });

    open MODULE_TEMPLATE, "> $out_dir/$module.html" or print "Could not open $out_dir/$module.html";
    printf MODULE_TEMPLATE $text or print "Could not write $out_dir/$module.html";
    close MODULE_TEMPLATE;

    if ($debug) {
        print "  wrote $out_dir/$module.html";
    }
}
