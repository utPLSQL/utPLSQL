CREATE OR REPLACE PACKAGE BODY utconfig
IS
/*
GNU General Public License for utPLSQL

Copyright (C) 2000
Steven Feuerstein, steven@stevenfeuerstein.com
Chris Rimmer, chris@sunset.force9.co.uk

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
*/
-------------------------------------------------------------------------------
--Description
-------------------------------------------------------------------------------
--This package manages the ut_config table, which holds the configuration 
--settings for different users.  The configuration data to be used by utPLSQL
--by default is set by calling settester.  Wherever a username is passed as NULL, 
--it is assumed to be that user.  This defaults initially to the current user.
-------------------------------------------------------------------------------
--Modification History
-------------------------------------------------------------------------------
--WHO                 WHEN         WHAT
-------------------------------------------------------------------------------
--Chris Rimmer        22 Oct 2000  Created from utplsql package
-------------------------------------------------------------------------------

----------------------------------------------------------------------------
--This record holds the default configuration
----------------------------------------------------------------------------
   g_config   ut_config%ROWTYPE   := NULL;

----------------------------------------------------------------------------
-- Get the configuration record for a user from the table
----------------------------------------------------------------------------   
   FUNCTION config (username_in IN VARCHAR2 := USER)
      RETURN ut_config%ROWTYPE
   IS
      rec   ut_config%ROWTYPE;
   BEGIN
      --Short cut for current user
      IF username_in = tester
      THEN
         RETURN g_config;
      END IF;

      BEGIN
         --Try to pull in the record from the table
         SELECT *
           INTO rec
           FROM ut_config
          WHERE username = UPPER (username_in);
      EXCEPTION
         --If we failed to find the record
         WHEN OTHERS
         THEN
            --Set the record to NULL
            rec := NULL;
      END;

      RETURN rec;
   END;

----------------------------------------------------------------------------
--This sets the configuration record for a user in the table
----------------------------------------------------------------------------
   PROCEDURE setconfig (
      field_in      IN   VARCHAR2
     ,value_in           VARCHAR2
     ,username_in   IN   VARCHAR2 := NULL
   )
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81

      --Local procedure to do dynamic SQL
      PROCEDURE do_dml (statement_in IN VARCHAR2)
      IS
      &start73 cursor_handle INTEGER; &end73
      &start73 rows INTEGER; &end73
      BEGIN
         --In 8i, just do it
         &start81 EXECUTE IMMEDIATE statement_in; COMMIT; &end81

           --Otherwise use DBMS_SQL
           &start73
         --Open the cursor
         cursor_handle := DBMS_SQL.open_cursor;
         -- Parse the Statement
         DBMS_SQL.parse (cursor_handle, statement_in, DBMS_SQL.native);
         -- Execute the Statement 
         ROWS := DBMS_SQL.EXECUTE (cursor_handle);
         -- Close the cursor 
         DBMS_SQL.close_cursor (cursor_handle);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_SQL.close_cursor (cursor_handle);
            RAISE;
      &end73
      END;
   BEGIN
      BEGIN
         --Try to insert the record
         do_dml (   'INSERT INTO ut_config(username, '
                 || field_in
                 || ')'
                 || 'VALUES ('''
                 || username_in
                 || ''', '''
                 || value_in
                 || ''')'
                );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            --Since it already exists, we'll update instead
            do_dml (   'UPDATE ut_config '
                    || 'SET '
                    || field_in
                    || ' = '''
                    || value_in
                    || ''' '
                    || 'WHERE username = '''
                    || username_in
                    || ''' '
                   );
         WHEN OTHERS
         THEN
            --Something else went wrong
            utplsql.pl (SQLERRM);
            &start81 ROLLBACK; &end81
            RETURN;
      END;

      &start81 COMMIT; &end81

      --If it's the current user, force update of package record
      IF username_in = tester
      THEN
         g_config := NULL;
         settester (username_in);
      END IF;
   END;

----------------------------------------------------------------------------
--This loads the default configuration from the table
----------------------------------------------------------------------------
   PROCEDURE settester (username_in IN VARCHAR2 := USER)
   IS
   BEGIN
      --Load the record
      g_config := config (username_in);
      --But set the username record if null
      g_config.username := NVL (g_config.username, UPPER (username_in));
   END;

----------------------------------------------------------------------------
-- Get the user we use by default
----------------------------------------------------------------------------
   FUNCTION tester
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_config.username;
   END;

----------------------------------------------------------------------------
-- Show the config for a user
----------------------------------------------------------------------------
   PROCEDURE showconfig (username_in IN VARCHAR2 := NULL)
   IS
      --The schema to show
      v_user   VARCHAR2 (32)       := NVL (username_in, tester);
      --This holds the configuration
      rec      ut_config%ROWTYPE;
   BEGIN
      --Get the configuration
      rec := config (v_user);
      --Now show it
      utplsql.pl ('============================================================='
                 );
      utplsql.pl ('utPLSQL Configuration for ' || v_user);
      utplsql.pl ('   Directory: ' || rec.DIRECTORY);
      utplsql.pl ('   Autcompile? ' || rec.autocompile);
      utplsql.pl ('   Manual test registration? ' || rec.registertest);
      utplsql.pl ('   Prefix = ' || rec.prefix);
      utplsql.pl ('   ----- File Output settings:');
      utplsql.pl ('   Output directory: ' || rec.filedir);
      utplsql.pl ('   Output flag     = ' || rec.fileout);
      utplsql.pl ('   User prefix     = ' || rec.fileuserprefix);
      utplsql.pl ('   Include progname? ' || rec.fileincprogname);
      utplsql.pl ('   Date format     = ' || rec.filedateformat);
      utplsql.pl ('   File extension  = ' || rec.fileextension);
      utplsql.pl ('   ----- End File Output settings');
      utplsql.pl ('============================================================='
                 );
   END;

----------------------------------------------------------------------------
-- Set the prefix for a user
----------------------------------------------------------------------------
   PROCEDURE setprefix (prefix_in IN VARCHAR2, username_in IN VARCHAR2 := NULL)
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('prefix', prefix_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the prefix for a user
----------------------------------------------------------------------------
   FUNCTION prefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return prefix
      RETURN NVL (rec.prefix, c_prefix);
   END;

----------------------------------------------------------------------------
-- Set the delimiter for a user
----------------------------------------------------------------------------
   PROCEDURE setdelimiter (
      delimiter_in   IN   VARCHAR2
     ,username_in    IN   VARCHAR2 := NULL
   )
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('delimiter', delimiter_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the delimiter for a user
----------------------------------------------------------------------------
   FUNCTION delimiter (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return prefix
      RETURN NVL (rec.delimiter, c_delimiter);
   END;

----------------------------------------------------------------------------
-- Set the source directory for a user
----------------------------------------------------------------------------
   PROCEDURE setdir (dir_in IN VARCHAR2, username_in IN VARCHAR2 := NULL)
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('directory', dir_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the source directory for a user
----------------------------------------------------------------------------
   FUNCTION dir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return directory
      RETURN rec.DIRECTORY;
   END;

----------------------------------------------------------------------------
-- Set the autocompile flag for a user
----------------------------------------------------------------------------
   PROCEDURE autocompile (onoff_in IN BOOLEAN, username_in IN VARCHAR2 := NULL)
   IS
      --Holds the flag as 'Y'/'N'
      v_autocompile   CHAR (1)       := utplsql.bool2vc (onoff_in);
      --Holds the user to set 
      v_user          VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('autocompile', v_autocompile, v_user);
   END;

----------------------------------------------------------------------------
-- Get the autocompile flag for a user
----------------------------------------------------------------------------
   FUNCTION autocompiling (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return autocompile, defaulting to TRUE if NULL
      RETURN NVL (utplsql.vc2bool (rec.autocompile), TRUE);
   END;

----------------------------------------------------------------------------
-- Set the manual registration flag for a user
----------------------------------------------------------------------------
   PROCEDURE registertest (onoff_in IN BOOLEAN, username_in IN VARCHAR2
            := NULL)
   IS
      --Holds the flag as 'Y'/'N'
      v_registertest   CHAR (1)       := utplsql.bool2vc (onoff_in);
      --Holds the username in question
      v_user           VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('registertest', v_registertest, v_user);
   END;

----------------------------------------------------------------------------
-- Get the manual registration flag for a user
----------------------------------------------------------------------------
   FUNCTION registeringtest (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return registertest, defaulting to FALSE if NULL
      RETURN NVL (utplsql.vc2bool (rec.registertest), FALSE);
   END;

   -- Show failures only?
   PROCEDURE showfailuresonly (
      onoff_in      IN   BOOLEAN
     ,username_in   IN   VARCHAR2 := NULL
   )
   IS
      --Holds the flag as 'Y'/'N'
      v_showfailuresonly   CHAR (1)       := utplsql.bool2vc (onoff_in);
      --Holds the username in question
      v_user               VARCHAR2 (100)
                                         := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('show_failures_only', v_showfailuresonly, v_user);
   END;

   FUNCTION showingfailuresonly (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return show_failures_only, defaulting to FALSE if NULL
      RETURN NVL (utplsql.vc2bool (rec.show_failures_only), FALSE);
   END;

-- RMM start
----------------------------------------------------------------------------
-- Set the file directory for a user
----------------------------------------------------------------------------
   PROCEDURE setfiledir (
      dir_in        IN   VARCHAR2 := NULL
     ,username_in   IN   VARCHAR2 := NULL
   )
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('filedir', dir_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the file output directory for a user
----------------------------------------------------------------------------
   FUNCTION filedir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return directory
      RETURN rec.filedir;
   END;

----------------------------------------------------------------------------
-- Set the file output flag for a user
----------------------------------------------------------------------------
   PROCEDURE setfile (
      fileout_in    IN   BOOLEAN := FALSE
     ,username_in   IN   VARCHAR2 := NULL
   )
   IS
      --Holds the flag as 'Y'/'N'
      v_fileout   CHAR (1)       := utplsql.bool2vc (fileout_in);
      --Holds the user to set
      v_user      VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('fileout', v_fileout, v_user);
   END;

----------------------------------------------------------------------------
-- Get the file output flag for a user
----------------------------------------------------------------------------
   FUNCTION getfile (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return autocompile, defaulting to TRUE if NULL
      RETURN NVL (utplsql.vc2bool (rec.fileout), FALSE);
   END;

----------------------------------------------------------------------------
-- Set the file prefix for a user
----------------------------------------------------------------------------
   PROCEDURE setuserprefix (
      userprefix_in   IN   VARCHAR2 := NULL
     ,username_in     IN   VARCHAR2 := NULL
   )
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('fileuserprefix', userprefix_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the file prefix for a user
----------------------------------------------------------------------------
   FUNCTION userprefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return directory
      RETURN rec.fileuserprefix;
   END;

----------------------------------------------------------------------------
-- Set the include program name flag for a user
----------------------------------------------------------------------------
   PROCEDURE setincludeprogname (
      incname_in    IN   BOOLEAN := FALSE
     ,username_in   IN   VARCHAR2 := NULL
   )
   IS
      --Holds the flag as 'Y'/'N'
      v_incname   CHAR (1)       := utplsql.bool2vc (incname_in);
      --Holds the user to set
      v_user      VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('fileincprogname', v_incname, v_user);
   END;

----------------------------------------------------------------------------
-- Get the include program name flag for a user
----------------------------------------------------------------------------
   FUNCTION includeprogname (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return autocompile, defaulting to TRUE if NULL
      RETURN NVL (utplsql.vc2bool (rec.fileincprogname), FALSE);
   END;

----------------------------------------------------------------------------
-- Set the date format for a user
----------------------------------------------------------------------------
   PROCEDURE setdateformat (
      dateformat_in   IN   VARCHAR2 := 'yyyyddmmhh24miss'
     ,username_in     IN   VARCHAR2 := NULL
   )
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('filedateformat', dateformat_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the date format for a user
----------------------------------------------------------------------------
   FUNCTION DATEFORMAT (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return directory
      RETURN rec.filedateformat;
   END;

----------------------------------------------------------------------------
-- Set the file extension for a user
----------------------------------------------------------------------------
   PROCEDURE setfileextension (
      fileextension_in   IN   VARCHAR2 := '.UTF'
     ,username_in        IN   VARCHAR2 := NULL
   )
   IS
      --The user to set
      v_user   VARCHAR2 (100) := NVL (UPPER (username_in), tester);
   BEGIN
      --Set the configuration
      setconfig ('fileextension', fileextension_in, v_user);
   END;

----------------------------------------------------------------------------
-- Get the file extension for a user
----------------------------------------------------------------------------
   FUNCTION fileextension (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      --Holds the user's config record
      rec      ut_config%ROWTYPE;
      --Holds the username in question
      v_user   VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --Return directory
      RETURN rec.fileextension;
   END;

----------------------------------------------------------------------------
-- Set all of the file output columns for a user
----------------------------------------------------------------------------
   PROCEDURE setfileinfo (
      fileout_in         IN   BOOLEAN := FALSE
     ,dir_in             IN   VARCHAR2 := NULL
     ,userprefix_in      IN   VARCHAR2 := NULL
     ,incname_in         IN   BOOLEAN := FALSE
     ,dateformat_in      IN   VARCHAR2 := 'yyyyddmmhh24miss'
     ,fileextension_in   IN   VARCHAR2 := '.UTF'
     ,username_in        IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      NULL;
      setfile (fileout_in, username_in);
      setfiledir (dir_in, username_in);
      setuserprefix (userprefix_in, username_in);
      setincludeprogname (incname_in, username_in);
      setdateformat (dateformat_in, username_in);
      setfileextension (fileextension_in, username_in);
   END setfileinfo;

----------------------------------------------------------------------------
-- Get all of the file output columns for a user
----------------------------------------------------------------------------
   FUNCTION fileinfo (username_in IN VARCHAR2 := NULL)
      RETURN rec_fileinfo
   IS
      --Holds the user's config record
      rec            ut_config%ROWTYPE;
      --Holds the username in question
      v_user         VARCHAR2 (100)      := NVL (UPPER (username_in), tester);
      -- Holds the return value
      fileinfo_rec   rec_fileinfo;
   BEGIN
      --Pull in the configuration
      rec := config (v_user);
      --populate the record
      fileinfo_rec.fileout := rec.fileout;
      fileinfo_rec.filedir := rec.filedir;
      fileinfo_rec.fileuserprefix := rec.fileuserprefix;
      fileinfo_rec.fileincprogname := rec.fileincprogname;
      fileinfo_rec.filedateformat := rec.filedateformat;
      fileinfo_rec.fileextension := rec.fileextension;
      --Return the record
      RETURN fileinfo_rec;
   END fileinfo;

-- RMM end

   PROCEDURE upd (
      username_in             IN   ut_config.username%TYPE
     ,autocompile_in          IN   ut_config.autocompile%TYPE
     ,prefix_in               IN   ut_config.prefix%TYPE
     ,show_failures_only_in   IN   ut_config.show_failures_only%TYPE
     ,directory_in            IN   ut_config.DIRECTORY%TYPE
     ,filedir_in              IN   ut_config.filedir%TYPE
     ,show_config_info_in     IN   ut_config.show_config_info%TYPE
     ,editor_in               IN   ut_config.editor%TYPE
   ) 
   IS
   &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
   BEGIN
      INSERT INTO ut_config
                  (username, autocompile, prefix
                  ,show_failures_only, DIRECTORY, filedir
                  ,show_config_info, editor
                  )
           VALUES (username_in, autocompile_in, prefix_in
                  ,show_failures_only_in, directory_in, filedir_in
                  ,show_config_info_in, editor_in
                  );
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- Perform an update instead.
         UPDATE ut_config
            SET autocompile = autocompile_in
               ,prefix = prefix_in
               ,show_failures_only = show_failures_only_in
               ,DIRECTORY = directory_in
               ,filedir = filedir_in
               ,show_config_info = show_config_info_in
          WHERE username = username_in;
      WHEN OTHERS
      THEN
         &start81 ROLLBACK; &end81
         NULL; -- Present to assist in formatting
   END;

   FUNCTION browser_contents (
      schema_in      IN   VARCHAR2
     ,name_like_in   IN   VARCHAR2 := '%'
     ,type_like_in   IN   VARCHAR2 := '%'
   )
      RETURN refcur_t
   IS
      retval   refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT ao.owner, ao.object_name, ao.object_type, ao.created
               ,ao.last_ddl_time, utrutp.last_run_status (
			   ao.owner, ao.object_name) status
           FROM all_objects ao
          WHERE ao.owner = UPPER (schema_in)	
		    AND ao.owner NOT IN ('SYS', 'SYSTEM', 'PUBLIC')	  
            AND object_name LIKE UPPER (name_like_in)
            AND object_type LIKE UPPER (type_like_in)
			AND object_type IN ('PACKAGE', 'FUNCTION', 'PROCEDURE', 'OBJECT TYPE');
      RETURN retval;
   END browser_contents;

   FUNCTION source_for_program (schema_in IN VARCHAR2, NAME_IN IN VARCHAR2)
      RETURN refcur_t
   IS
      retval   refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT line, text
           FROM all_source
          WHERE owner = UPPER (schema_in) AND NAME = UPPER (NAME_IN);
      RETURN retval;
   END source_for_program;
	  
   FUNCTION onerow (schema_in IN VARCHAR2)
      RETURN refcur_t
   IS
      retval   refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT autocompile, DIRECTORY, filedir, prefix, show_failures_only
               ,show_config_info, editor
           FROM ut_config
          WHERE username = UPPER (schema_in);
   END onerow;

   PROCEDURE get_onerow (
      schema_in                IN       VARCHAR2
     ,username_out             OUT      VARCHAR2
     ,autocompile_out          OUT      ut_config.autocompile%TYPE
     ,prefix_out               OUT      ut_config.prefix%TYPE
     ,show_failures_only_out   OUT       ut_config.show_failures_only%TYPE
     ,directory_out            OUT      ut_config.DIRECTORY%TYPE
     ,filedir_out              OUT      ut_config.filedir%TYPE
     ,show_config_info_out     OUT      ut_config.show_config_info%TYPE
     ,editor_out               OUT      ut_config.editor%TYPE
   )
   IS
   BEGIN
      SELECT username, autocompile, DIRECTORY, filedir
            ,prefix, show_failures_only, show_config_info
            ,editor
        INTO username_out, autocompile_out, directory_out, filedir_out
            ,prefix_out, show_failures_only_out, show_config_info_out
            ,editor_out
        FROM ut_config
       WHERE username = UPPER (schema_in);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         username_out := NULL;
   END get_onerow;
BEGIN
   --Initially, set the user as default tester
   settester;
END;
/
