CREATE OR REPLACE PACKAGE BODY Utfilereporter
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

  g_fid     UTL_FILE.FILE_TYPE;

  PROCEDURE record_error (str IN VARCHAR2)
  IS
  BEGIN
    UtOutputReporter.pl('UTL_FILE error: ' || str);
    Utfilereporter.CLOSE(bool_abort => TRUE);
  END;

  PROCEDURE open_file(dir VARCHAR2, filename VARCHAR2, filemode VARCHAR2 := 'A')
  IS
  BEGIN
    
      IF g_fid.ID IS NOT NULL THEN
        close_file;
      END IF;
    
  	  g_fid := UTL_FILE.FOPEN (dir, filename, filemode);             
             
  EXCEPTION
    WHEN UTL_FILE.INVALID_PATH
     THEN record_error ('invalid_path');
     RAISE;
    WHEN UTL_FILE.INVALID_MODE
     THEN record_error ('invalid_mode');
     RAISE;
    WHEN UTL_FILE.INVALID_FILEHANDLE
     THEN record_error ('invalid_filehandle');
     RAISE;
    WHEN UTL_FILE.INVALID_OPERATION
     THEN record_error ('invalid_operation');
     RAISE;
    WHEN UTL_FILE.READ_ERROR
     THEN record_error ('read_error');
     RAISE;
    WHEN UTL_FILE.WRITE_ERROR
     THEN record_error ('write_error');
     RAISE;
    WHEN UTL_FILE.INTERNAL_ERROR
     THEN record_error ('internal_error');
     RAISE;
  END; 

  PROCEDURE close_file
  IS
  BEGIN

    UTL_FILE.FCLOSE (g_fid);
    g_fid.ID := NULL;
    
  EXCEPTION
    WHEN UTL_FILE.INVALID_PATH
     THEN record_error ('invalid_path');
     RAISE;
    WHEN UTL_FILE.INVALID_MODE
     THEN record_error ('invalid_mode');
     RAISE;
    WHEN UTL_FILE.INVALID_FILEHANDLE
     THEN record_error ('invalid_filehandle');
     RAISE;
    WHEN UTL_FILE.INVALID_OPERATION
     THEN record_error ('invalid_operation');
     RAISE;
    WHEN UTL_FILE.READ_ERROR
     THEN record_error ('read_error');
     RAISE;
    WHEN UTL_FILE.WRITE_ERROR
     THEN record_error ('write_error');
     RAISE;
    WHEN UTL_FILE.INTERNAL_ERROR
     THEN record_error ('internal_error');
     RAISE;     
  END; 
      
  PROCEDURE OPEN
  IS
  
  	 file_dir   UT_CONFIG.filedir%TYPE; 
     userprefix UT_CONFIG.fileuserprefix%TYPE; 
     incprog    UT_CONFIG.fileincprogname%TYPE; 
     extension  UT_CONFIG.fileextension%TYPE;	

     no_dir EXCEPTION;
  
  BEGIN

  	  -- Get the output file directory
	  file_dir := Utconfig.filedir ();
      --  check if NULL
      IF file_dir IS NULL THEN
        -- try directory
        file_dir := Utconfig.dir ();
        --  check if NULL
        IF file_dir IS NULL THEN
          record_error('No directory specified for file output');
          RAISE no_dir;
	    END IF;
      END IF;

	  -- Get the userprefix from config
	  userprefix := Utconfig.userprefix();
	  IF userprefix IS NULL THEN
	    -- use the current user if userprefix IS NULL
		userprefix := USER;
      END IF;
	  userprefix := userprefix ||'_';

	  -- get the file extension
	  extension := Utconfig.fileextension();
	  
	  open_file (file_dir, userprefix || TO_CHAR(SYSDATE,Utconfig.dateformat)||extension);

 	  pl('-- '||TO_CHAR(SYSDATE,Utconfig.dateformat));             
             
  END; 

  PROCEDURE CLOSE(bool_abort BOOLEAN := FALSE)
  IS
  BEGIN
    IF NOT bool_abort THEN
 	  pl('-- '||TO_CHAR(SYSDATE,Utconfig.dateformat));             
    END IF;
    
    close_file;
  END; 
   
  PROCEDURE pl (str IN VARCHAR2) 
  IS
  BEGIN

    -- write input to file
    UTL_FILE.PUT_LINE (g_fid, str);
 
  EXCEPTION
    WHEN UTL_FILE.INVALID_PATH
     THEN record_error ('invalid_path');
     RAISE;
    WHEN UTL_FILE.INVALID_MODE
     THEN record_error ('invalid_mode');
     RAISE;
    WHEN UTL_FILE.INVALID_FILEHANDLE
     THEN record_error ('invalid_filehandle');
     RAISE;
    WHEN UTL_FILE.INVALID_OPERATION
     THEN record_error ('invalid_operation');
     RAISE;
    WHEN UTL_FILE.READ_ERROR
     THEN record_error ('read_error');
     RAISE;
    WHEN UTL_FILE.WRITE_ERROR
     THEN record_error ('write_error');
     RAISE;
    WHEN UTL_FILE.INTERNAL_ERROR
     THEN record_error ('internal_error');
     RAISE;
  END pl;

BEGIN
  g_fid.ID := NULL;    
END;
/
