/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE uttestprep
-- NO LONGER USED.
IS
   FUNCTION setup_program (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;

   FUNCTION teardown_program (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2;
END;
/
