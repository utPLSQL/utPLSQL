CREATE OR REPLACE PACKAGE utconfig &start81 AUTHID CURRENT_USER &end81
IS
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

   --The default prefix
   c_prefix      CONSTANT CHAR (3) := 'ut_';
   --The default delimiter
   c_delimiter   CONSTANT CHAR (2) := '##';

   -- RMM start
   -- Record definition used by fileinfo function
   TYPE rec_fileinfo IS RECORD (
      fileout           ut_config.fileout%TYPE
     ,filedir           ut_config.filedir%TYPE
     ,fileuserprefix    ut_config.fileuserprefix%TYPE
     ,fileincprogname   ut_config.fileincprogname%TYPE
     ,filedateformat    ut_config.filedateformat%TYPE
     ,fileextension     ut_config.filedateformat%TYPE
   );

   -- RMM end

   TYPE refcur_t IS REF CURSOR;

   CURSOR browser_cur
   IS
      SELECT owner, object_name, object_type, created, last_ddl_time, status
        FROM all_objects;

   cursor source_cur
   IS
     SELECT line, text FROM all_source;
	 
   -- Set the user whose configuration we use by default
   PROCEDURE settester (username_in IN VARCHAR2 := USER);

   -- Get the user we use by default
   FUNCTION tester
      RETURN VARCHAR2;

   -- Display the current configuration settings
   PROCEDURE showconfig (username_in IN VARCHAR2 := NULL);

   -- Set the default prefix
   PROCEDURE setprefix (prefix_in IN VARCHAR2, username_in IN VARCHAR2 := NULL);

   -- Get the default prefix
   FUNCTION prefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- 2.0.7 Switch to delimiter for V2
   -- Set the default delimiter
   PROCEDURE setdelimiter (
      delimiter_in   IN   VARCHAR2
     ,username_in    IN   VARCHAR2 := NULL
   );

   -- Get the default delimiter
   FUNCTION delimiter (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set location of source code
   PROCEDURE setdir (dir_in IN VARCHAR2, username_in IN VARCHAR2 := NULL);

   -- Get location of source code
   FUNCTION dir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set autocompile flag
   PROCEDURE autocompile (onoff_in IN BOOLEAN, username_in IN VARCHAR2 := NULL);

   -- Get autocompile flag
   FUNCTION autocompiling (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   -- Set manual registration flag
   PROCEDURE registertest (onoff_in IN BOOLEAN, username_in IN VARCHAR2
            := NULL);

   -- Get manual registration flag
   FUNCTION registeringtest (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   /* start 2.0.10.1 additions */
   -- Show failures only?
   PROCEDURE showfailuresonly (
      onoff_in      IN   BOOLEAN
     ,username_in   IN   VARCHAR2 := NULL
   );

   FUNCTION showingfailuresonly (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   /* end 2.0.10.1 additions */

   -- RMM start
   -- Get the directory for file output   
   FUNCTION filedir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set the file output flag
   PROCEDURE setfile (
      fileout_in    IN   BOOLEAN := FALSE
     ,username_in   IN   VARCHAR2 := NULL
   );

   -- Get the file output flag for a user
   FUNCTION getfile (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   -- Set the file prefix for a user
   PROCEDURE setuserprefix (
      userprefix_in   IN   VARCHAR2 := NULL
     ,username_in     IN   VARCHAR2 := NULL
   );

   -- Get the file prefix for a user
   FUNCTION userprefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set the include program name flag for a user
   PROCEDURE setincludeprogname (
      incname_in    IN   BOOLEAN := FALSE
     ,username_in   IN   VARCHAR2 := NULL
   );

   -- Get the include program name flag for a user
   FUNCTION includeprogname (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   -- Set the date format for a user
   PROCEDURE setdateformat (
      dateformat_in   IN   VARCHAR2 := 'yyyyddmmhh24miss'
     ,username_in     IN   VARCHAR2 := NULL
   );

   -- Get the date format for a user
   FUNCTION DATEFORMAT (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set the file extension for a user
   PROCEDURE setfileextension (
      fileextension_in   IN   VARCHAR2 := '.UTF'
     ,username_in        IN   VARCHAR2 := NULL
   );

   -- Get the file extension for a user
   FUNCTION fileextension (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set all of the file output columns for a user
   PROCEDURE setfileinfo (
      fileout_in         IN   BOOLEAN := FALSE
     ,dir_in             IN   VARCHAR2 := NULL
     ,userprefix_in      IN   VARCHAR2 := NULL
     ,incname_in         IN   BOOLEAN := FALSE
     ,dateformat_in      IN   VARCHAR2 := 'yyyyddmmhh24miss'
     ,fileextension_in   IN   VARCHAR2 := '.UTF'
     ,username_in        IN   VARCHAR2 := NULL
   );

   -- Get all of the file output columns for a user
   FUNCTION fileinfo (username_in IN VARCHAR2 := NULL)
      RETURN rec_fileinfo;

   -- RMM end        

   -- 2.1.1: Single update and insert procedure
   PROCEDURE upd (
      username_in             IN   ut_config.username%TYPE
     ,autocompile_in          IN   ut_config.autocompile%TYPE
     ,prefix_in               IN   ut_config.prefix%TYPE
     ,show_failures_only_in   IN   ut_config.show_failures_only%TYPE
     ,directory_in            IN   ut_config.DIRECTORY%TYPE
     ,filedir_in              IN   ut_config.filedir%TYPE
     ,show_config_info_in     IN   ut_config.show_config_info%TYPE
     ,editor_in               IN   ut_config.editor%TYPE
    );

   /* The upd procedure does an insert if no row exists.
   PROCEDURE add (
     username_in IN ut_config.username%TYPE,
     AUTOCOMPILE_in IN ut_config.AUTOCOMPILE%TYPE := 'N',
     prefix_in in ut_config.prefix%TYPE := c_prefix,
     SHOW_FAILURES_ONLY_in in ut_config.SHOW_FAILURES_ONLY%TYPE := 'N',
     directory_in IN ut_config.directory%TYPE := NULL,
     FILEDIR_in in ut_config.FILEDIR%TYPE := NULL,
     show_config_info_in in ut_config.show_config_info%TYPE := 'Y') ;
   */
   FUNCTION browser_contents (
      schema_in      IN   VARCHAR2
     ,name_like_in   IN   VARCHAR2 := '%'
     ,type_like_in   IN   VARCHAR2 := '%'
   )
      RETURN refcur_t;

   /*
   Sample usage:

   DECLARE
      rc    utconfig.refcur_t;
      rec   utconfig.browser_cur%ROWTYPE;
   BEGIN
      rc := utconfig.browser_contents (USER);

      LOOP
         FETCH rc INTO rec;
         EXIT WHEN rc%NOTFOUND;
         p.l (rec.object_name);
      END LOOP;
   END;
   */
   
   FUNCTION source_for_program (
      schema_in      IN   VARCHAR2
     ,name_in   IN   VARCHAR2
   )
      RETURN refcur_t;
	  
   FUNCTION onerow (schema_in IN VARCHAR2)
      RETURN refcur_t;

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
   );
END;
/
