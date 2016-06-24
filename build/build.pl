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
# This perl script can do the following
#  1.  Call the build_docs.pl to generate the documentation.
#  2.  Create ZIP File for Release
#      - Creates a "release" directory underneath the current directory.
#      - Copies all the files for a release into this new directory.
#      - Creates a zip file (the file that gets released) with the correct name.
#  3.  Commit/Push the latest documentation to the utPLSQL.github.io repository.
#
# Please see <https://github.com/utPLSQL/utPLSQL/wiki/Release-Procedure> for
# the Release Procedure.
#

use strict;
use warnings;
use 5.010;


use Cwd;
use Cwd 'abs_path';
use File::Spec;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
say "---------------------------------------------------------------";
say " NOTE: Requires GIT SSH Keys to be setup to Update Web Docs.";
say "---------------------------------------------------------------";
say "Which build option do you require:";
say "  1) Create release ";
say "     - Update Docs, Create Zip";
say "  2) Create release and update website ";
say "     - Update Docs,Create Zip,Update Web Docs";
say "  3) Build and Update the website documentation without release";
say "     - Update Docs,Update Web Docs";
say "---------------------------------------------------------------";
print "Please make selection: ";
my $selection = <>;
chop $selection;

if    ($selection eq 1) { regenerate_docs();
                          create_zip_release();}
elsif ($selection eq 2) { regenerate_docs();
                          create_zip_release();
						  update_website();}
elsif ($selection eq 3) { regenerate_docs();
                          update_website(); }
else { die "Invalid selection - exiting \n"; }

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
    copy ("../readme.md", release_dir());
}


sub populate_code_directory {
    dircopy ("../source", release_code_dir());
}


sub populate_doc_directory{
    dircopy ("../documentation/output", release_doc_dir());
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
#Left here not used, but could be readded if desired later.
    my $confirmed;

    print "Please confirm you wish to upload this release: [".version_number()."] (Y/N)? ";
    $confirmed = <>;
    chomp $confirmed;

    if (!($confirmed eq "Y" || $confirmed eq "y")) {
        die "Not confirmed - aborting \n";
    }

    create_zip_release();
#    upload_zip();

}


sub regenerate_docs {
# Change working directory so that build_docs.pl can find the files.
 my $orig_dir = cwd;
 chdir '../documentation/src/';
 system 'build_docs.pl';             
 chdir $orig_dir;
}


sub confirm_update_docs {
    my $confirmed;
    print "Please confirm you wish to update documentation on web: (Y/N)? ";
    $confirmed = <>;
    chomp $confirmed;
    my $result = 0;
    if (($confirmed eq "Y" || $confirmed eq "y")) {
        $result = 1;
    }
	return $result;
}	
sub setup_repo {    
	if (!(-d '.git')) {
	   system 'git clone git@github.com:utPLSQL/utPLSQL.github.io.git .';
	}
    system 'git checkout master';
	system 'git pull';
}
sub copy_docs{
    my $builddir = $_[0];
	my $repodir  = $_[1];
	my @bdirs = File::Spec->splitdir($builddir);
	pop @bdirs;
	my @rdirs = File::Spec->splitdir($repodir);
	my $doc_output = File::Spec->catdir(@bdirs,'documentation','output');         
	my $doc_repo = File::Spec->catdir(@rdirs,'docs');
    dircopy ($doc_output, $doc_repo);  
}

sub add_and_commit{
  system 'git add .';
  my $output = qx/git status --porcelain/;
  my $result = 0;
  if ($output ne '') {
    system 'git commit -m "Automated Doc Refresh from utPLSQL repo"';	
	$result = 1;	
  }
  return $result;
}


sub push_changes{
   system 'git push';
}

sub update_website {
   
    my $website_repo = ask_for_website_repo(); 
	my $orig_cwd = cwd;
	
	if (!(-d $website_repo)) {
	   make_dir $website_repo; 
	}	
	my $abs_website = abs_path($website_repo);
    
	chdir $website_repo;	
	
	setup_repo();
	copy_docs($orig_cwd,$abs_website);
	if (add_and_commit($abs_website) == 0){
	  say "No Doc changes to commit and push."
	}
	else {
	  if (confirm_update_docs() == 1) {
	    push_changes();
	  } 
	}
	cwd $orig_cwd;
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

sub ask_for_website_repo {
	my $web_repo_path;

	say 'Please enter local working copy location of utPLSQL.github.io repository ';
	say '  Press "Enter" for defaults of "../../utPLSQL.github.io" ';
	$web_repo_path = <>;

	chomp $web_repo_path;

	if ($web_repo_path eq "") {
		$web_repo_path = "../../utPLSQL.github.io";
	  }
	  
	return $web_repo_path;  
} 
