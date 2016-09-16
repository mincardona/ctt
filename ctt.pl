#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

# First, parse command line args.
# Then, get key data.
# Then, process file data and write to output files.

# slurp the file
sub slrp {
    my $fname = shift @_;
    open(my $FILE, "<$fname") or return "";
    my @lines = <$FILE>;
    close($FILE);
    # lines still have newlines on the end, so join on empty string
    return join("", @lines);
}

# arrays of input file strings and corresponding output file strings
my @infiles = ();
my @outfiles = ();

# true if the -o flag was used to start a list of output files
my $output_flag_seen = 0;

my %opts = ();

# verbose
getopts('v', \%opts);

if (@ARGV < 3) {
    print "ctt, the C++ code template utility\n";
    print "Usage:\n";
    print "\tctt [flags] keyfile templatefile [templatefiles...] -o outputfile [outputfiles...]\n";
    print "Keyfile format:\n";
    print "\t# comment\n";
    print "\tKEY0=VALUE0\n";
    print "\tKEY1=VALUE1\n";
    print "\tFor input files, - is shorthand for stdin\n";
    print "\tFor output files, - is shorthand for stdout\n";
    exit;
}

# read names of input and output files
for my $arg (@ARGV) {
    if (not $output_flag_seen) {
        if ($arg eq "-o") {
            $output_flag_seen = 1;
        # an input file name of "-" signifies stdin
        } elsif ($arg eq "-") {
            push @infiles, "/dev/stdin";
        } else {
            print "selecting $arg as input file\n" if $opts{'v'};
            push @infiles, $arg;
        }
    } else {
        # an output file name of "-" signifies stdout
        if ($arg eq "-") {
            push @outfiles, "/dev/stdout";
        } else {
            print "selecting $arg as output file\n" if $opts{'v'};
            push @outfiles, $arg;
        }
    }
}

my $keyfile_name = shift @infiles;

my $nof_infiles = scalar @infiles;
my $nof_outfiles = scalar @outfiles;

($nof_infiles == $nof_outfiles) or die "[ERR]  $nof_infiles input files provided, but $nof_outfiles output files provided";

# parse the keyfile

# read keyfile as array of lines
open(my $KEYFILE, "<$keyfile_name") or die "[ERR]  Couldn't open keyfile: $keyfile_name";
my @lines = <$KEYFILE>;
close($KEYFILE);

# hash of keyword->replacement substitutions
my %subs = ();
# track line number
my $line_n = 0;

# read in all key/value pairs from keyfile
for my $line (@lines) {

    $line_n++;
    
    # remove trailing newline
    chomp $line;
    
    # skip line comments
    if (substr($line, 0, 1) eq "#" or length($line) == 0) {
        next;
    }
    
    # TODO: keywords must be prefixed with /*$
    # get index of first = character
    $line =~ m/=/;
    my $splitpoint = $-[0];
    $splitpoint >= 0 or die "[ERR]  No = present in keyfile on line $line_n";
    
    # extract keyword
    my $keyword = substr $line, 0, $splitpoint;
    length($keyword) > 0 or die "[ERR]  Empty keyword in keyfile on line $line_n";
    
    # extract replacement text
    my $replace_with = substr $line, $splitpoint+1;
    $subs{$keyword} = $replace_with;
    
}

print "performing replacements...\n" if $opts{'v'};

# perform replacement on the infiles and write results to outfiles
for my $i (0 .. $#infiles) {
    print "performing replacements in $infiles[$i]\n" if $opts{'v'};
    my $contents = slrp($infiles[$i]);
    
    while (my ($key, $value) = each %subs) {
        # replaces /*$KEY*/
        $contents =~ s/\/\*\$$key\*\//$value/g;
    }
    
    open(my $outfile, ">" . $outfiles[$i]) 
        or die "[ERR]  Couldn't open output file" . $outfiles[$i];
    
    print $outfile $contents;
    
    close ($outfile);
}

print "done.\n" if $opts{'v'};

