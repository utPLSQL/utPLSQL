#!/usr/bin/perl -w
#
# This perl script builds the documentation for utPLSQL
# $Id$
#

use strict;

#The directory the output goes into
my $OUTDIR = "..";

#Holds the map
my @map;

#Holds the top navigation string
my $nav = "";

#Read the map file
open MAP, "map.txt" or die "Cannot open map.txt";
my ($filename,$desc,$section);
while (<MAP>){

	#Ignore lines starting with #, or empty
	if (not /^#/ and /\S/){
		chomp;

		#Split on comma
		($filename, $desc) = split /,/;

		$section = 0;

		#Add entries ending in * to navigation bar
		if ($desc =~ s/\*$//){
			$nav .= " | " if $nav;
			$nav .= "<A href=\"$filename\">$desc</A>\n";
			$section = 1;
		}
		push @map, [$filename, $desc, $section];
	}
}
close MAP;

#Add the document map
push @map, ["map.html", "Document Map", 1];
$nav = "[ $nav | <A href=\"map.html\">Document Map</A> ]";

#Hold the copyright strings
my $copyright;
my $copymeta;
my $authormeta;

#Read the authors file
open AUTHORS, "authors.txt" or die "Cannot open authors.txt";
my ($name, $email);
while (<AUTHORS>){

	#Ignore lines starting with #, or empty
	if (not /^#/ and /\S/){
		chomp;
		($name, $email) = split /,/;
		$copyright .= ', ' if $copyright;
		$copyright .= "<A href=\"mailto:$email\">$name<A>";
		$authormeta .= ', ' if $authormeta;
		$authormeta .= $name;
	}
}
close AUTHORS;

#Put together the rest of the copyright notices
$copyright = "Copyright (C) 2000-".(((gmtime(time))[5])+1900)." $copyright All rights reserved";
$copymeta = "(C) 2000-".(((gmtime(time))[5])+1900)." $authormeta";

my $logo = '<div class="purple_bar"><a href="index.html"><img src="utplsql.jpg" border=0></a></div>';

#Now build the documentation
my $index;
my $body;
my $nextprev;
foreach $index (0..$#map){

	if ($index != 0){
		$nextprev = '<A href="'.($map[$index-1]->[0]).'">&lt; Previous Section: '.($map[$index-1]->[1]).'</A>';
	} else {
		$nextprev = '';
	}
	if ($index != $#map){
		$nextprev .= ' | ' if $nextprev;
		$nextprev .= '<A href="'.($map[$index+1]->[0]).'">Next Section: '.($map[$index+1]->[1]).' &gt;</A>';
	}	

	$body = 0;
	open OUTPUT, ">$OUTDIR/$map[$index]->[0]" or die "Cannot open $OUTDIR/$map[$index]->[0]";

	if ($index != $#map){
		system("./clean_html.pl $map[$index]->[0] > $map[$index]->[0].clean");
		open INPUT, "$map[$index]->[0].clean" or die "Cannot open $map[$index]->[0].clean";
	}

	print OUTPUT "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">\n\n\n";
	print OUTPUT "<!-- WARNING! This file is generated. -->\n";
	print OUTPUT "<!-- To alter documentation, edit files in src directory -->\n\n\n";
	print OUTPUT "<html><head>\n";
	print OUTPUT "<title>$map[$index]->[1]</title>\n";
	print OUTPUT "<link rel=\"stylesheet\" href=\"utplsql.css\" content=\"text/css\">\n";
	print OUTPUT "<meta name=\"keywords\" content=\"utPLSQL, PL\\SQL, Unit Testing, Framework, Oracle\"/>\n";
        print OUTPUT "<meta name=\"description\" content=\"Unit Testing PL\\SQL\"/>\n";
	print OUTPUT "<meta name=\"title\" content=\"$map[$index]->[1]\"/>\n";
	print OUTPUT "<meta name=\"author\" content=\"$authormeta\"/>\n";
	print OUTPUT "<meta name=\"copyright\" content=\"$copymeta\"/>\n";
	print OUTPUT "</head><body>\n";
	print OUTPUT "$logo\n";
	print OUTPUT "<p>$nav</p>\n";
	print OUTPUT "<p>$nextprev</p>\n";

	#Either print the body, or construct it for the document map 
	if ($index != $#map){
		while (<INPUT>){
			if (/(<!-- Begin utPLSQL Body -->.*)/){
				$_ = "$1\n";
				$body = 1;
			}
			if (/(.*<!-- End utPLSQL Body -->)/i){
				$body = 0;
				print OUTPUT "$1\n";
			}
			print OUTPUT $_ if $body;
		}
		close INPUT;
		unlink("$map[$index]->[0].clean");
	} else {
		print OUTPUT "<h1>Document Map</h1>\n";
		foreach (@map){
			if ($_->[2]){
				print OUTPUT "<b>";
			} else {
				print OUTPUT "&nbsp;&nbsp;";
			}
			print OUTPUT "<A href=\"$_->[0]\">$_->[1]</A><br>";
			print OUTPUT "</b>" if $_->[2];
			print OUTPUT "\n";
		}
	}

	print OUTPUT "<p>$nextprev</p>\n";
	print OUTPUT "$logo\n";
	print OUTPUT "<p class=\"copyright\">$copyright</p>\n";
	print OUTPUT "</body></html>";	
	close OUTPUT;
}

