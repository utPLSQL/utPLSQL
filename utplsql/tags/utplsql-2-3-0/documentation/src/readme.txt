==================================
HOW TO BUILD UTPLSQL DOCUMENTATION
==================================
$Id$
==================================

The utPLSQL documentation is built from a series of simple HTML files in the
src directory.  These files have none of the navigation bars, logos or
next/previous links which appear in the final documentation.  They are also
stripped of font, color and style information at compile-time to let the
stylesheet (utplsql.css) determine the overall look-and-feel. 

---------
THE FILES
---------

The files are compiled into a documentation set situated in the top-level
documentation directory using the 2 control files, map.txt and authors.txt.
The first of these is the driving file, giving a list of the files to be
included.  The second gives a list of authors to be included in the copyright
notice on each page and referenced in the Meta tags.

The format of map.txt is as follows:

   # Any line starting with a # is 
   # considered a comment
   #
   index.html,Home*
   started.html,Getting Started*
   another.html,Further Docs
   another2.html,Yet more docs

Each line consists of the filename to be included and the title of the page,
separated with a comma. Any file whose title is followed by an asterisk is
considered the start of a new section.  This means a link to the file will
appear in the navigation bar at the top of each page and it will appear in
bold in the document map.  Note that the document map itself does not appear
in map.txt, but is always added at the end and is considered a new section.
This page is entirely generated at compile-time.

The format of authors.txt is as follows:

   # Again, lines starting # are ignored
   #
   Steven Feuerstein,steven@stevenfeuerstein.com
   Chris Rimmer,c@24.org.uk
   A N Other,ano@ther.net

Each line in this file simply gives the name of the author and their email
address, separated with a comma. 

-----------
THE SCRIPTS
-----------

The 2 Perl scripts used to build the documentation are clean_html.pl and
build_docs.pl. 

The first of these simply strips HTML files down to the basics, removing
everything from the header and removing Javascript, fonts, color etc.  It
requires the HTML::TagFilter module which in turn also requires the
HTML::Parser and HTML::Tagset modules (all available from search.cpan.org).

The second script goes through each file listed in map.txt, cleans it using
the previous script and then adds logos, navigation bars, next/previous links,
copyright information etc.  The resulting files are put in the top-level
documentation directory. 

NOTE: Anything within a source file before the
"<!-- Begin utPLSQL Body -->" comment line and after the 
"<!-- End utPLSQL Body -->" comment line is ignored. 
