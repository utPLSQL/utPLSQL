CREATE OR REPLACE PACKAGE utconfig &start81 AUTHID CURRENT_USER &end81
IS

   --The default prefix
   c_prefix CONSTANT CHAR (3) := 'ut_';

   -- Set the user whose configuration we use by default
   PROCEDURE setuser (username_in IN VARCHAR2 := USER);

   -- Get the user we use by default
   FUNCTION getuser RETURN VARCHAR2;
   
   -- Display the current configuration settings
   PROCEDURE showconfig (username_in IN VARCHAR2 := NULL);

   -- Set the default prefix
   PROCEDURE setprefix (prefix_in IN VARCHAR2, username_in IN VARCHAR2 := NULL);

   -- Get the default prefix
   FUNCTION prefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set location of source code
   PROCEDURE setdir (dir_in IN VARCHAR2, username_in IN VARCHAR2 := NULL);

   -- Get location of source code
   FUNCTION dir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

   -- Set autocompile flag
   PROCEDURE autocompile (
      onoff_in IN BOOLEAN,
      username_in IN VARCHAR2 := NULL
   );

   -- Get autocompile flag
   FUNCTION autocompiling (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

   -- Set manual registration flag
   PROCEDURE registertest (
      onoff_in IN BOOLEAN,
      username_in IN VARCHAR2 := NULL
   );

   -- Get manual registration flag
   FUNCTION registeringtest (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN;

END;
/
 

