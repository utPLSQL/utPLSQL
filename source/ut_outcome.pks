/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE utoutcome
IS
   c_name     CONSTANT CHAR (7) := 'OUTCOME';
   c_abbrev   CONSTANT CHAR (2) := 'OC';

   FUNCTION name (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome.name%TYPE;

   FUNCTION id (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome.id%TYPE;

   FUNCTION onerow (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome%ROWTYPE;

   FUNCTION onerow (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome%ROWTYPE;

   FUNCTION utp (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_utp.id%TYPE;

   PRAGMA restrict_references (utp, WNDS, WNPS);

   FUNCTION unittest (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_unittest.id%TYPE;

   PRAGMA restrict_references (unittest, WNDS, WNPS);
END utoutcome;
/
