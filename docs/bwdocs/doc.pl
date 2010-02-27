#!/usr/bin/perl

# for examples look here:
# http://pub.ocpsys.com/bashworks/break.html


use strict;
use warnings;

use Text::Template;
use Cwd 'realpath';
use Text::Template 'fill_in_file';


my ($template_dir               , $out_dir          , $debug                  , $tpldebug                        ) =
   ( $ENV{"docs_template_path"} , $ENV{"docs_path"} , $ENV{"docs_debug"} || 0 , $ENV{"docs_template_debug"} || 0 );



print "Templates dir (env \$docs_template_path): $template_dir\n";
print "Documentation output (env \$docs_path): $out_dir\n";
print "Debug (env \$docs_debug): $debug\n";
print "Template debug (env \$docs_template_debug): $tpldebug\n";


my (
	%module_paths,
	%module_file,
	%module_var,
	%module_func,
	%file_module,
	%file_doc,
	%file_relative,
	%file_link,
	%file_anchor,
	%relative_file,
	%func_lines,
	%func_files,
	%func_modules,
	%func_doc,
	%func_link,
	%var_lines,
	%var_files,
	%var_modules,
	%var_doc,
	%var_link,
	%var_type,
	%var_default
);

foreach my $arg (@ARGV) {
	$_ = $arg;
	if (/\/$/) {
		print "ERROR: paths to module repositories should not have trailing slashes!\n";
		die;
	}
	# find modules and submodules
	my @sources = split(/\n/, `find $arg -name source.sh`);
	foreach(@sources) {
		s/\/source\.sh//;
		my $path = realpath($_);
		s/($arg)\///;
		s/\//_/;
		$module_paths{$_} = $path;
	}
}

print "Phase 1: finding modules (_pre_source)\n"
if $debug;

# find scripts and their belonging module
# longest module name first
foreach my $module (reverse sort { length($module_paths{$a}) cmp length($module_paths{$b}) } keys %module_paths) {

	my $path = $module_paths{$module};

	if ( $debug ) {
		print "- $module from $path:\n";
	}

	my @scripts = split(/\n/, `find "$path" -name "*.sh"`);

	foreach(@scripts) {
		my $script = $_;

		next if
		( (/bashunit/ || /shunit/) && ( $module !~ /^mtests_/) ) ||
		(grep($_ eq $script, keys %file_module));

		$file_module{$_}                 = $module;
		my $absolute                     = $_;

		$_                               = $module;
		s/_/\//g;
		my $module_rel                   = $_;

		$_                               = $absolute;
		s/^.*($module_rel)/$module_rel/;
		my $relative                     = $_;
		$file_relative{$absolute}        = $relative;
		$relative_file{$relative}        = $absolute;
		s/\//_/g;
		$file_anchor{$absolute}          = $_;
		$file_link{$absolute}            = $module . ".html#" . $file_anchor{$absolute};
		$module_file{$module}            = $absolute;

		print "  absolute path: $absolute\n  relative path: $relative\n  anchor: $file_anchor{$absolute}\n"
		if $debug;
	}    
}

print "Phase 2: analysing modules (source)\n"
if $debug;

# find docblocks and their belonging functions
foreach my $script (keys %file_module) {
	my $module = $file_module{$script};

    print "- $module"
    if $debug;

	open SCRIPT, "< $script";

	my $line= 1;
	my $current_doc = "";
	my $current_func = "";
	my $script_doc = "";
	while(<SCRIPT>) {

		if (/^# / || /^##/) {
			# function current_docblock
			$current_doc .= $_;
		} elsif (/^\n$/ and $current_doc and $script_doc eq "") {
			# script doc end
			$file_doc{$script} = $current_doc;
			$script_doc        = $current_doc;
			$current_doc       = "";
		} elsif (/^function ([^ (]*)/) {
			# function declaration
			$current_func                = $1;
			$func_lines{$current_func}   = $line;
			$func_files{$current_func}   = $script;
			$func_modules{$current_func} = $module;
			$func_link{$current_func}    = $module . ".html#" .$current_func;
			$module_func{$module}        = 1;
		} elsif (/^declare -([a-zA-Z]) ([a-zA-Z0-9_-]+)(=(.*))?/) {
			my $current_var            = $2;
			$var_lines{$current_var}   = $line;
			$var_files{$current_var}   = $script;
			$var_modules{$current_var} = $module;
			$var_link{$current_var}    = $module . ".html#" .$current_var;
			$var_default{$current_var} = $4;
			$var_doc{$current_var}     = $current_doc;
			$module_var{$module}       = 1;
			$_                         = $1;
			if (/A/) {
				$var_type{$current_var} = "Associative array";
			} elsif (/a/) {
				$var_type{$current_var} = "Array";
			} elsif (/i/) {
				$var_type{$current_var} = "Integer";
			} else {
				$var_type{$current_var} = "?";
			}
			$current_doc = "";
		} elsif (/^(declare )?([a-zA-Z0-9_-]+)=(.*)/) {
			my $current_var            = $2;
			$var_lines{$current_var}   = $line;
			$var_files{$current_var}   = $script;
			$var_modules{$current_var} = $module;
			$var_link{$current_var}    = $module . ".html#" .$current_var;
			$var_default{$current_var} = $3;
			$var_doc{$current_var}     = $current_doc;
			$module_var{$module}       = 1;
			$_                         = $3;
			if (/[0-9]+/) {
				$var_type{$current_var} = "Integer";
			} elsif (/^\(/) {
				$var_type{$current_var} = "Array (Associative?)";
			} elsif (/^"/) {
				$var_type{$current_var} = "String";
			} else {
				$var_type{$current_var} = "?";
			}
			$current_doc = "";
		} elsif (/mlog ([^ ]+) ['"]([^'"]+)['"]/) {
			$current_doc .= "# \@log $1 $2\n"
		} elsif (/^}/) {
			# function end, do clean
			$func_doc{$current_func} = $current_doc;
			$current_doc             = "";
			$current_func            = "";
		}

		$line++;
	}

	close SCRIPT;

	print "  done reading $script" 
    if $debug;
}

print "Phase 3: rendering\n"
if $debug;

for my $module ( keys %module_paths ) {

	print "- $module:\n" 
    if $debug;

	my $template = 
	Text::Template->new(
		TYPE => 'FILE',
		SOURCE => $template_dir . '/module_index.html'
	)
		or die "Couldn't construct template: $Text::Template::ERROR";

	my $text = $template->fill_in( HASH => {
			"module_name"   => \$module,
			"template_dir"  => \$template_dir,
			"out_dir"       => \$out_dir,
			"debug"         => \$debug,
			"tpldebug"      => \$tpldebug,
			"module_paths"  => \%module_paths,
			"module_var"    => \%module_var,
			"module_func"   => \%module_func,
			"module_file"   => \%module_file,
			"file_module"   => \%file_module,
			"file_doc"      => \%file_doc,
			"file_relative" => \%file_relative,
			"file_link"     => \%file_link,
			"file_anchor"   => \%file_anchor,
			"relative_file" => \%relative_file,
			"func_lines"    => \%func_lines,
			"func_link"     => \%func_link,
			"func_files"    => \%func_files,
			"func_modules"  => \%func_modules,
			"func_doc"      => \%func_doc,
			"var_lines"     => \%var_lines,
			"var_link"      => \%var_link,
			"var_files"     => \%var_files,
			"var_modules"   => \%var_modules,
			"var_doc"       => \%var_doc,
			"var_type"      => \%var_type,
			"var_default"   => \%var_default,
		});

	open MODULE_TEMPLATE, "> $out_dir/$module.html" or print "Could not open $out_dir/$module.html";
	printf MODULE_TEMPLATE $text                    or print "Could not write $out_dir/$module.html";
	close MODULE_TEMPLATE;

	print "  wrote $out_dir/$module.html" 
    if $debug;
}
