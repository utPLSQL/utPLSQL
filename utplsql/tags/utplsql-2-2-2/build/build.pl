#!/usr/bin/perl -w
# ************************************************************************
# GNU General Public License for utPLSQL
# 
# Copyright (C) 2014 
# Steven Feuerstein and the utPLSQL Project
# (steven@stevenfeuerstein.com)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program (see license.txt); if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# ************************************************************************
#
# This perl script builds and optionally uploads a release of utPLSQL.
#
# Please see <https://sourceforge.net/p/utplsql/wiki/Release%20Procedure/> for
# the Release Procedure.
#
# Creating a release does the following:
#  - Creates a "release" directory underneath the current directory.
#  - Copies all the files for a release into this new directory.
#  - Creates a zip file (the file that gets released) with the correct name.
#
# Uploading a release does all the above, plus the following:
#  - Uploads the release zip to Sourceforge (it will become visible in the File 
#    Download area, but will not be the default).
#  - Uploads the website.
#
# $Id$
#

use strict;
use warnings;
use 5.010;

use File::Copy;
use File::Copy::Recursive qw(dircopy);
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

say "Which build option do you require:";
say "  1) Create release";
say "  2) Create and upload release";
print "Please make selection: ";
my $selection = <>;

given($selection) {
    when(1) {create_zip_release();}
    when(2) {upload_release();}
    default {
        die "Invalid selection - exiting \n";
    }
}


sub version_number {
    state $version;
    my $confirmed;

    if (!defined $version) {
        print "What is the new version number? ";
        $version = <>;
        chomp $version;
        print "Please confirm new version number: [$version] (Y/N)? ";
        $confirmed = <>;

        chomp $confirmed;

        if (!($confirmed eq "Y" || $confirmed eq "y")) {
            die "Not confirmed - aborting \n";
        }
    }

    return $version;
}


sub release_dir {
    return "release-" . version_number();
}


sub release_code_dir {
    return release_dir() . "/code";
}


sub release_doc_dir {
    return release_dir() . "/doc";
}

sub release_examples_dir {
    return release_dir() . "/examples";
}


sub create_release_directories {
    make_dir(release_dir());
    make_dir(release_code_dir());
    make_dir(release_doc_dir());
    make_dir(release_examples_dir());
}


sub make_dir {
    my($dir) = @_;
    unless(mkdir $dir) {
        die "Unable to create $dir - aborting \n";
    }
}


sub populate_release_directories {
    create_release_directories();
    populate_code_directory();
    populate_doc_directory();
    populate_examples_directory();
    copy ("../documentation/readme.txt", release_dir());
}


sub populate_code_directory {
    dircopy ("../source", release_code_dir());
}


sub populate_doc_directory{
    dircopy ("../website/Doc", release_doc_dir());
}


sub populate_examples_directory{
    dircopy ("../examples", release_examples_dir());
}


sub zip_filename {
    my $zipname = "utplsql-" . version_number() ;
    $zipname =~ s/[\.]/-/g;
    $zipname .= ".zip";
}


sub create_zip_release {
    populate_release_directories();
    my $zip = Archive::Zip->new();

   # Add a directory
   my $dir_member = $zip->addTree(release_dir());


    unless ( $zip->writeToFileNamed(zip_filename()) == AZ_OK ) {
        die "Error creating zip file " . zip_filename() . " \n";
   }
}


sub upload_release {
    my $confirmed;

    print "Please confirm you wish to upload this release: [".version_number()."] (Y/N)? ";
    $confirmed = <>;
    chomp $confirmed;

    if (!($confirmed eq "Y" || $confirmed eq "y")) {
        die "Not confirmed - aborting \n";
    }

    create_zip_release();
    upload_zip();
    upload_website();
    #set_default_download();
}


sub upload_zip {
    system 'rsync -avP -e ssh ' . zip_filename() . ' ' . username() . '@frs.sourceforge.net:/home/pfs/project/utplsql/utPLSQL/' . version_number() . '/' . zip_filename();
}


sub upload_website {
    system 'rsync -avP -chmod=Du=rwx,Dg=rx,Do=rx,Fu=rw,Fg=r,Fo=r -e ssh ../website/ ' . username() . '@web.sourceforge.net:/home/project-web/utplsql/htdocs/';
}


sub username {
    state $username;

    if (!defined $username) {
        print "Please enter your Sourceforge username: ";
        $username = <>;
        chomp $username;
    }

    return $username;
}
