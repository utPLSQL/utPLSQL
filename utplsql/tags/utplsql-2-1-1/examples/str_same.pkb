CREATE OR REPLACE PACKAGE BODY str
IS
   FUNCTION betwn (
      string_in IN VARCHAR2,
      start_in IN PLS_INTEGER,
      end_in IN PLS_INTEGER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (
                SUBSTR (
                   string_in,
                   start_in,
                   end_in - start_in + 1
                )
             );
   END;
END str;
/
