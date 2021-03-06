#!/usr/bin/perl -w
## ---------------------------------------------------------------------
##
## Copyright (c) 2007 - 2020 by the IBAMR developers
## All rights reserved.
##
## This file is part of IBAMR.
##
## IBAMR is free software and is distributed under the 3-clause BSD
## license. The full text of the license can be found in the file
## COPYRIGHT at the top level directory of IBAMR.
##
## ---------------------------------------------------------------------

#
# filename: set_spring_stiffness.pl
# author: Boyce Griffith
# usage: set_spring_stiffness.pl <input filename> <stiffness> <output filename>
#
# A simple Perl script to set the spring stiffnesses in an IBAMR input
# file by a uniform, user-specified amount.

if ($#ARGV != 2) {
    die "incorrect number of command line arguments.\nusage:\n  set_spring_stiffness.pl <input filename> <stiffness> <output filename>\n";
}

# parse the command line arguments
$input_filename = shift @ARGV;  chomp $input_filename;
$stiff = shift @ARGV;  chomp $stiff;
$output_filename = shift @ARGV;  chomp $output_filename;

print "input file: $input_filename\n";
print "stiffness: $stiff\n";
print "output file: $output_filename\n";

# open the input and output files
if ($input_filename eq $output_filename) {
    die "error: input and output files must be different\n";
}
if (-e $output_filename) {
    print "warning: about to overwrite contents of $output_filename\n";
    print "press [Enter] to continue...";  <STDIN>;
}

open(IN, "$input_filename") || die "error: cannot open $input_filename for reading: $!";
open(OUT, ">$output_filename") || die "error: cannot open $output_filename for writing: $!";

# the first line in the input file has the format:
#
#   <number of edges> (comments)
#
# where items in ()'s are optional
$_ = <IN>;
chomp;
@line = split;
for ($i = 0; $i <= $#line; $i++) {
    $a = $line[$i];

    if (($i == 0) && ($a =~ /^[+-]?\d+$/)) {
	printf OUT "%6d", $a; # integer
    }
    else
    {
	print OUT $a;
    }

    if ($i < $#line) {
	print OUT " ";
    }
    else {
	print OUT "\n";
    }
}

# the remaining lines in the input file all have the format:
#
#   <first node> <second node> <stiffness> <rest length> (force fcn index) (comments)
#
# where items in ()'s are optional
while (<IN>) {
    chomp;
    @line = split;
    for ($i = 0; $i <= $#line; $i++) {
	$a = $line[$i];

	if ($i == 2) {
	    $a = $stiff; # reset the stiffness
	}

	if (($i == 0 || $i == 1 || $i == 4) && ($a =~ /^[+-]?\d+$/)) {
	    printf OUT "%6d", $a; # integer
	}
	elsif ($i == 2 || $i == 3) {
	    printf OUT "%1.16e", $a; # floating point value
	}
	else {
	    print OUT $a;
	}

	if ($i < $#line) {
	    print OUT " ";
	}
	else {
	    print OUT "\n";
	}
    }
}

# close the input and output files
close(IN) || die "error: cannot close $input_filename: $!";
close(OUT) || die "error: cannot close $output_filename: $!";
