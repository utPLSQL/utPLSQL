CREATE OR REPLACE FUNCTION betwnStr (
   string_in IN VARCHAR2,
   start_in IN INTEGER,
   end_in IN INTEGER
   )
   RETURN VARCHAR2
IS
BEGIN
   raise value_Error;
   
   RETURN ( 
      SUBSTR (
         string_in, 
         start_in,
         end_in - start_in + 1
         )
      );
END;
/
CREATE OR REPLACE PACKAGE BODY ut_betwnstr
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;
   
   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   -- For each program to test...
   PROCEDURE ut_BETWNSTR IS
   BEGIN
      utAssert.throws (
         'NDF',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 3
            ,
            END_IN => 5
            ),
            -6502
         );
         
         
   END ut_BETWNSTR;

END ut_betwnstr;
/
