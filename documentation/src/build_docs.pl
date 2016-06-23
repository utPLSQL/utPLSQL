#!/usr/bin/perl -w
#
# This perl script builds the documentation for utPLSQL
# $Id$
#

use strict;
use warnings;
use 5.010;
use File::Copy;


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

my $outputpath = '..\output';
mkdir($outputpath);
output_doc_dir($outputpath);

sub output_doc_dir {
    #The directory the output goes into
    my ($OUTDIR) = @_;
    
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
    
    copy ("utplsql.css", "$OUTDIR");
    copy ("utplsql.jpg", "$OUTDIR");
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
    my ($src_filename) = @_;

    my $body = "";
    my $in_body;
    open (my $src_file, '<', $src_filename) or die "Cannot open $src_filename $!";
    while (<$src_file>){
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
    close $src_file;

    return $body
}


sub html_docmap {
    my $body;
        $body = "<h1>Document Map</h1>\n";
    foreach (@map){
        $body .= "<p>";
        if ($_->[2]){
            $body .= "<b>";
        } else {
            $body .= "&nbsp;&nbsp;";
        }
        $body .= "<a href=\"$_->[0]\">$_->[1]</a>";
        $body .= "</b>" if $_->[2];
        $body .= "</p>";
    }

    return $body;
}


sub html_footer {
    my $footer;
    $footer  = "   <p>$nextprev</p>\n\n";
    $footer .= logo()."\n\n";
    $footer .= "   <p>\n";
    $footer .= "      <a href=\"http://validator.w3.org/check?uri=referer\">\n";
    $footer .= "         <img src=\"http://www.w3.org/Icons/valid-xhtml10\" alt=\"Valid XHTML 1.0 Strict\" height=\"31\" width=\"88\" />\n";
    $footer .= "      </a>\n";
    $footer .= "   </p>\n\n";
    $footer .= "   <p class=\"copyright\">$copyright</p>\n";
    $footer .= "</body>\n";
    $footer .= "</html>";

    return $footer;
}