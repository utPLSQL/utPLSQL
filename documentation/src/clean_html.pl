#!/usr/bin/perl -w

# This Perl script cleans HTML for inclusion
# in the documentation
#
# $Id$
#

use HTML::TagFilter;
use strict;

#Make a tag filter object

my $tf = HTML::TagFilter->new(
	strip_comments => 0,
	skip_xss_protection => 1);

#Allow these tags	
$tf->allow_tags({ title => {none=>[]}, 
                   body => {none=>[]},
		   head => {none=>[]},
		   html => {none=>[]},
		  table => {any=>[]},
		     tr => {any=>[]},
		     td => {any=>[]}});

#...but get rid of style attributes
$tf->deny_tags({ table => {style=>[]},
                 tr => {style=>[]},
	         td => {style=>[]}});
		     
#Build up a string consisting of the
#whole file
my $dirty;
while (<>){
	$dirty .= $_;
}

#Scrub it 
my $clean = $tf->filter($dirty);

#Now I do my own special cleaning...

#Remove nbsp - use <br> instead!
$clean =~ s/&nbsp;/ /gs;

#Strip those <![]> tags out
$clean =~ s/<!\[[^>]*>//gs;

#Remove everything from head but the title
$clean =~ s/<head>.*<title>/<head><title>/gs;
$clean =~ s/<\/title>.*<\/head>/<\/title><\/head>/gs;

#Remove </pre><pre> pairs with just whitespace between
$clean =~s/<\/pre>\s*<pre>/\n/gs;

print $clean;
