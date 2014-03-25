#!/usr/bin/perl -w
#
# This perl script builds the documentation for utPLSQL
# $Id$
#

use strict;
use warnings;
use 5.010;
use HTML::TagFilter;

#The directory the output goes into
my $OUTDIR = '..';

#Holds the map
my @map;

#Holds the top navigation string
my $nav = '';

#Hold the copyright strings
my $copyright;
my $copymeta;
my $authormeta;
my $copyrightyears;

populate_map();
build_copyright();

#Now build the documentation
my $index;
my $nextprev;
foreach $index (0..$#map){

    open (my $outfile, '>', "$OUTDIR/$map[$index]->[0]") or die "Cannot open $OUTDIR/$map[$index]->[0] $!";
    build_nextprev($index);

    print $outfile html_header($map[$index]->[1]);

    #Either print the body, or construct it for the document map
    if ($index != $#map){
        print $outfile html_main("$map[$index]->[0]");
    } else {
        print $outfile html_docmap();
    }

    print $outfile html_footer();
    close $outfile;
}


sub populate_map {
    #Read the map file
    open (my $mapfile, '<', 'map.txt') or die "Cannot open map.txt $!";
    my ($filename,$desc,$section);

    while (<$mapfile>){
        #Ignore lines starting with #, or empty
        if (not /^#/ and /\S/){
            chomp;

            #Split on comma
            ($filename, $desc) = split /,/;

            $section = 0;

            #Add entries ending in * to navigation bar
            if ($desc =~ s/\*$//){
                $nav .= " | " if $nav;
                $nav .= "<a href=\"$filename\">$desc</a>\n";
                $section = 1;
            }
            push @map, [$filename, $desc, $section];
        }
    }
    close $mapfile;

    #Add the document map
    push @map, ["map.html", "Document Map", 1];
    $nav = "[ $nav | <a href=\"map.html\">Document Map</a> ]";
}


sub build_copyright {
    #Read the authors file
    open (my $authorsfile, '<', 'authors.txt') or die "Cannot open authors.txt $!";
    my ($name, $email);
    while (<$authorsfile>){

        #Ignore lines starting with #, or empty
        if (not /^#/ and /\S/){
            chomp;
            ($name, $email) = split /,/;
            $copyright .= ', ' if $copyright;
            $copyright .= "<a href=\"mailto:$email\">$name</a>";
            $authormeta .= ', ' if $authormeta;
            $authormeta .= $name;
        }
    }
    close $authorsfile;
    
    #Read the copyright_years file
    open (my $copyrightyearsfile, '<', 'copyright_years.txt') or die "Cannot open copyright_years.txt $!";
    my $year;
    while (<$copyrightyearsfile>){

        #Ignore lines starting with #, or empty
        if (not /^#/ and /\S/){
            chomp;
            $copyrightyears .= ', ' if $copyrightyears;
            $copyrightyears .= $_;
        }
    }
    close $copyrightyearsfile;
    
    $copyright .= ' and the utPLSQL Project';
    $authormeta .= ' and the utPLSQL Project';

    #Put together the rest of the copyright notices
    $copyright = "Copyright &copy; $copyrightyears $copyright. All rights reserved";
    $copymeta = "(C) $copyrightyears $authormeta";
}


sub logo {
    return '   <div class="purple_bar"><a href="index.html"><img src="utplsql.jpg" alt="utPLSQL logo" /></a></div>';
}


sub build_nextprev {
    my ($index) = @_;

    if ($index != 0){
        $nextprev = '<a href="'.($map[$index-1]->[0]).'">&lt; Previous Section: '.($map[$index-1]->[1]).'</a>';
    } else {
        $nextprev = '';
    }
    if ($index != $#map){
        $nextprev .= ' | ' if $nextprev;
        $nextprev .= '<a href="'.($map[$index+1]->[0]).'">Next Section: '.($map[$index+1]->[1]).' &gt;</a>';
    }
}

sub html_header {
    my ($page_title) = @_;
    my $head;
    $head  = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n";
    $head .= "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\n\n";
    $head .= "<!-- WARNING! This file is generated. -->\n";
    $head .= "<!-- To alter documentation, edit files in src directory -->\n\n\n";
    $head .= "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n";
    $head .= "<head>\n";
    $head .= "   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
    $head .= "   <title>$page_title</title>\n";
    $head .= "   <link rel=\"stylesheet\" href=\"utplsql.css\" type=\"text/css\" />\n";
    $head .= "   <meta name=\"keywords\" content=\"utPLSQL, PL\\SQL, Unit Testing, Framework, Oracle\" />\n";
    $head .= "   <meta name=\"description\" content=\"Unit Testing PL\\SQL\" />\n";
    $head .= "   <meta name=\"title\" content=\"$page_title\" />\n";
    $head .= "   <meta name=\"author\" content=\"$authormeta\" />\n";
    $head .= "   <meta name=\"copyright\" content=\"$copymeta\" />\n";
    $head .= "</head>\n";
    $head .= "<body>\n";
    $head .= logo()."\n";
    $head .= "   <p>$nav</p>\n";
    $head .= "   <p>$nextprev</p>\n";

    return $head;
}


sub html_main {
    my ($dirty_filename) = @_;
    my $clean_filename = "$dirty_filename.clean";

    clean_file($dirty_filename);

    my $body = "";
    my $in_body;
    open (my $clean_file, '<', $clean_filename) or die "Cannot open $clean_filename $!";
    while (<$clean_file>){
        if (/(<!-- Begin utPLSQL Body -->.*)/){
            $_ = "$1\n";
            $in_body = 1;
        }
        if (/(.*<!-- End utPLSQL Body -->)/i){
            $in_body = 0;
            $body .= "$1\n";
        }
         $body .= $_ if $in_body;
    }
    close $clean_file;
    unlink($clean_filename);

    return $body
}


sub html_docmap {
    my $body;
        $body = "<h1>Document Map</h1>\n";
    foreach (@map){
        if ($_->[2]){
            $body .= "<b>";
        } else {
            $body .= "&nbsp;&nbsp;";
        }
        $body .= "<a href=\"$_->[0]\">$_->[1]</a><br>";
        $body .= "</b>" if $_->[2];
        $body .= "\n";
    }

    return $body;
}


sub html_footer {
    my $footer;
    $footer  = "   <p>$nextprev</p>\n\n";
    $footer .= logo()."\n\n";
    $footer .= "   <p class=\"copyright\">$copyright</p>\n";
    $footer .= "</body>\n";
    $footer .= "</html>";

    return $footer;
}

sub clean_file {
    my $tf = HTML::TagFilter->new(
    strip_comments => 0,
    skip_xss_protection => 1);

    #Allow these tags
    $tf->allow_tags({ title => {none=>[]},
                  body  => {none=>[]},
                  head  => {none=>[]},
                  html  => {none=>[]},
                  table => {any=>[]},
                  tr    => {any=>[]},
                  td    => {any=>[]}});

    #...but get rid of style attributes
    $tf->deny_tags({ table => {style=>[]},
                     tr    => {style=>[]},
                     td    => {style=>[]}});


    my ($dirtyfilename) = @_;
    my $cleanfilename = "$dirtyfilename.clean";

    open(my $dirtyfile, '<', "$dirtyfilename") or die "Unable to open $dirtyfilename $!";
    open(my $cleanfile, '>', "$cleanfilename") or die "Unable to open $cleanfilename $!";

    my $dirtydata;
    my $cleandata;

    #Build up a string consisting of the
    #whole file
    while (<$dirtyfile>){
        $dirtydata .= $_;
    }

    #Scrub it
    $cleandata = $tf->filter($dirtydata);

    #Now I do my own special cleaning...

    #Remove nbsp - use <br> instead!
    $cleandata =~ s/&nbsp;/ /gs;

    #Strip those <![]> tags out
    $cleandata =~ s/<!\[[^>]*>//gs;

    #Remove everything from head but the title
    $cleandata =~ s/<head>.*<title>/<head><title>/gs;
    $cleandata =~ s/<\/title>.*<\/head>/<\/title><\/head>/gs;

    #Remove </pre><pre> pairs with just whitespace between
    $cleandata =~s/<\/pre>\s*<pre>/\n/gs;

    print $cleanfile $cleandata;

    close $dirtyfile;
    close $cleanfile;
}