CREATE OR REPLACE PACKAGE BODY uthtmlreporter
IS
   
/************************************************************************
GNU General Public License for utPLSQL

Copyright (C) 2000-2003 
Steven Feuerstein and the utPLSQL Project
(steven@stevenfeuerstein.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see license.txt); if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
************************************************************************
$Log$
Revision 1.1  2004/07/14 17:01:57  chrisrimmer
Added first version of pluggable reporter packages
 

************************************************************************/


   PROCEDURE open
   IS

  	 file_dir   UT_CONFIG.filedir%TYPE; 
     no_dir EXCEPTION;
  
   BEGIN

  	  -- Get the output file directory
	  file_dir := Utconfig.filedir ();
      --  check if NULL
      IF file_dir IS NULL THEN
        Utoutputreporter.pl('UTL_FILE error: No directory specified for file output');
        Utfilereporter.CLOSE(bool_abort => TRUE);
        RAISE no_dir;
      END IF;
	  
	  utfilereporter.open_file (file_dir, TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '.html', 'W');

      pl('<HTML><HEAD><TITLE>Test Results</TITLE></HEAD><BODY>');
      
   END;

   PROCEDURE close
   IS
   BEGIN
     pl('</BODY></HTML>');
     utfilereporter.close_file;
   END;   
   
   PROCEDURE pl (str VARCHAR2)
   IS
   BEGIN
     utfilereporter.pl(str);
   END;   

   PROCEDURE pl_success
   IS
   BEGIN
     pl('<FONT COLOR="#00ee11">Success</FONT>');
   END;

   PROCEDURE pl_failure
   IS
   BEGIN
     pl('<FONT COLOR="#ff0000">FAILURE</FONT>');
   END;

   PROCEDURE before_results(run_id IN utr_outcome.run_id%TYPE)
   IS
   BEGIN
      pl('<H1>'|| utplsql.currpkg || ': ');
      IF utresult.success (run_id) THEN
        pl_success;
      ELSE
        pl_failure;
      END IF;

      pl('</H1><BR>Results:<TABLE BORDER=1>');
      pl('<TR><TD><B>Status</B></TD><TD><B>Description</B></TD></TR>');
      
   END;
   
   PROCEDURE show_failure
   IS
   BEGIN
     pl('<TR><TD>');
     pl_failure;
     pl('</TD><TD>' || utreport.outcome.description || '</TD></TR>');
   END;
   
   PROCEDURE show_result
   IS
   BEGIN
     pl ('<TR><TD>');
     
     IF utreport.outcome.status = 'SUCCESS' THEN
       pl_success;
     ELSE
       pl_failure;
     END IF;       

     pl('</TD><TD>' || utreport.outcome.description || '</TD></TR>');
   END;
   
   PROCEDURE after_results(run_id IN utr_outcome.run_id%TYPE)
   IS
   BEGIN
     pl('</TABLE>');
   END;
   
   PROCEDURE before_errors(run_id IN utr_error.run_id%TYPE)
   IS
   BEGIN      
     pl('Errors:<br><TABLE BORDER=1>');
     pl('<TR><TD><B>Error Level</B></TD><TD><B>Error Code</B></TD><TD><B>Description</B></TD></TR>');     
   END;
   
   PROCEDURE show_error
   IS
   BEGIN
     utreport.pl ('<TR><TD>' || utreport.error.errlevel || 
                  '</TD><TD>' || utreport.error.errcode || 
                  '</TD><TD>' || utreport.error.errtext || '</TD></TR>');
   END;
   
   PROCEDURE after_errors(run_id IN utr_error.run_id%TYPE)
   IS
   BEGIN
     pl('</TABLE>');     
   END;   
   
END uthtmlreporter;
/
