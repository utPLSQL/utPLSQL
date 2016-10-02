#!/usr/bin/perl
use strict;
use warnings;
use IPC::System::Simple qw(system);
use Markdent::Simple::Document;
use Markdent::Simple::Fragment;
use File::Map qw(map_file);
use File::Path qw(make_path);
use Cwd 'abs_path';

use constant false => 0;
use constant true  => 1;

main();

sub main{
    # change current working directory to location of script.
    # this keeps realative paths later in script easier to maintain.
    # Source:  https://sysengineers.wordpress.com/2009/12/04/changing-working-directory-to-script-location-in-perl/
    my $path = abs_path($0);
    $path =~ s/builddocs.pl//gi;
    chdir ($path);

    # Create output directories if the don't exists
	make_path("../docs");
	
	# Execute NaturalDocs 
	# -i InputDirectory
	# -o FramedHTML or HTML OutputDirectory  (Using HTML so we can directly link to documenation pages easier.)
	# -p ProectDirectory
	# -xi ExcludeDirFromInput
	# -r RebuildAllFiles	
	my @nd_args = qw(      
		  -i ../ 
		  -o HTML ../docs/ 
		  -p ./project 
		  -xi ../.travis 
		  -xi ../examples 
		  -xi ../lib 
		  -xi ../tools 
		  -xi ../build 
		  -r
		  );	  
    system($^X, "../tools/ndocs/NaturalDocs", @nd_args);
    
	#convert markdown files to html 
    #convert_markdown_file("../CONTRIBUTING.md","../docs/files/docsource/topics/contributing-txt.html","How to contribute to utPLSQL");
	convert_markdown_and_insert("../CONTRIBUTING.md","../docs/files/docsource/topics/contributing-txt.html");
	
	
	
	#Checking for current/past errors with NaturalDocs
	check_project_file_for_error("project/Menu.txt");		
	check_project_file_for_error("project/Languages.txt");		
    check_project_file_for_error("project/Topics.txt");				
	if (-e "project/LastCrash.txt")	 {
	   die "project/LastCrash.txt found, indicating a prior NaturalDocs problem that should be fixed.  Note: File must be manually removed to continue";
	 }
}

sub check_project_file_for_error {
  my $file_to_check = shift;
  map_file(my $menufile,$file_to_check); 
  if ($menufile =~ /ERROR/) { die "ERROR found $file_to_check" }
}  

sub convert_markdown {
   my $markdowntext = shift;
   my $fragment = shift;
   my $title = shift;  

   # convert markdown to html  
   my $htmltext;
   if ($fragment = true) {
       my $parser = Markdent::Simple::Fragment->new();
       $htmltext   = $parser->markdown_to_html(
						  markdown => $markdowntext);  
   } else {
     my $parser = Markdent::Simple::Document->new();
     $htmltext   = $parser->markdown_to_html(
						  markdown => $markdowntext,
						  title => $title);
   }
 
   #return 
   $htmltext;						     
}

sub convert_markdown_and_insert {
   my $source = shift;
   my $dest = shift;   
   
   # memory map input file
   map_file(my $markdown, $source);    
   
   # convert markdown to html
   my $html = convert_markdown($markdown,true);
   
   # read output file
   open FILE, "<$dest" or die "Couldn't open file: $!";
   binmode FILE;
   my $output = do { local $/; <FILE> };
   close FILE;
   
   #search and replace
   $output =~ s/$source/$html/g;
     
   # write output file
   open FILE, ">$dest" or die "Couldn't open file: $!";
   binmode FILE;
   print FILE $output;
   close FILE;
   
}

sub convert_markdown_file {
   my $source = shift;
   my $dest = shift;   
   my $title = shift;  
  
   # memory map input file
   map_file(my $markdown, $source);   
  
   # convert markdown to html
   my $html = convert_markdown($markdown,false,$title);

   # check output file exists, and deletes.		   
   if (-f $dest)  {
	   unlink $dest or die "Cannot delete $dest: $!";								  
   }
   
   # write markdown to file
   my $OUTFILE;
   open $OUTFILE, '>>', $dest or die "Cannot open $dest";
   print { $OUTFILE } $html or die "Cannot write to $dest";
   close $OUTFILE or die "Cannot close $dest";
   
   print "Converted $source to $dest" 
}













