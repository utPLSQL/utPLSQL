CREATE OR REPLACE PACKAGE str
IS
   FUNCTION betwn (
      string_in IN VARCHAR2,
      start_in IN PLS_INTEGER,
      end_in IN PLS_INTEGER
   )
      RETURN VARCHAR2;     
END str;
/
