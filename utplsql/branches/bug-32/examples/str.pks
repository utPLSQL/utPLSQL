/* Formatted on 2001/11/19 15:11 (Formatter Plus v4.5.2) */
CREATE OR REPLACE PACKAGE str
IS
   FUNCTION betwn (
      string_in   IN   VARCHAR2,
      start_in    IN   PLS_INTEGER,
      end_in      IN   PLS_INTEGER
   )
      RETURN VARCHAR2;

   FUNCTION betwn2 (
      string_in   IN   VARCHAR2,
      start_in    IN   PLS_INTEGER,
      end_in      IN   PLS_INTEGER
   )
      RETURN VARCHAR2;

   PROCEDURE ut_setup;

   PROCEDURE ut_teardown;

   -- For each program to test...
   PROCEDURE ut_betwn;
END str;
/

