/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY uttestprep
IS
   FUNCTION setup_program (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      return null;
   END setup_program;

   FUNCTION teardown_program (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      return null;
   END teardown_program;
END;
/
