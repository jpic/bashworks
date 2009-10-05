#!/usr/bin/perl

use Text::Template;
use Cwd 'realpath';
use Text::Template 'fill_in_file';

my $template_dir = "/tmp/templates";
my $out_dir = "/tmp/out";
my %module_paths = ();
my %file_module = ();
my %file_doc = ();
my %file_relative = ();
my %func_lines = ();
my %func_files = ();
my %func_modules = ();
my %func_doc = ();
my %func_link = ();

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
        print $module, " ", $_, "\n";
        #print "  ", $absolute, $_, "\n";
    }    
}

# find docblocks and their belonging functions
foreach $script (keys %file_module) {
    $module = $file_module{$script};

    open SCRIPT, "< $script";

    $line= 1;
    $current_doc = "";
    $current_func = "";
    $script_doc = "";
    while(<SCRIPT>) {
        if (/^# /) {
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
}

for $module ( keys %module_paths ) {
    $template = Text::Template->new(TYPE => 'FILE',  SOURCE => '/tmp/templates/module_index.html')
      or die "Couldn't construct template: $Text::Template::ERROR";

    $text = $template->fill_in( HASH => {
        "module_name" => \$module,
        "template_dir" => \$template_dir,
        "out_dir" => \$out_dir,
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

    open MODULE_TEMPLATE, "> $out_dir/$module.html";
    printf MODULE_TEMPLATE $text;
    close MODULE_TEMPLATE;
}
