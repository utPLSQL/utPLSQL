/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utoutcome
IS
   FUNCTION name (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome.name%TYPE
   IS
      retval   ut_outcome.name%TYPE;
   BEGIN
      SELECT name
        INTO retval
        FROM ut_outcome
       WHERE id = outcome_id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION id (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome.id%TYPE
   IS
      retval   ut_outcome.id%TYPE;
   BEGIN
      SELECT id
        INTO retval
        FROM ut_outcome
       WHERE name = name_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION onerow (name_in IN ut_outcome.name%TYPE)
      RETURN ut_outcome%ROWTYPE
   IS
      retval      ut_outcome%ROWTYPE;
      empty_rec   ut_outcome%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM ut_outcome
       WHERE name = name_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   FUNCTION onerow (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_outcome%ROWTYPE
   IS
      retval      ut_outcome%ROWTYPE;
      empty_rec   ut_outcome%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM ut_outcome
       WHERE id = outcome_id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   FUNCTION utp (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_utp.id%TYPE
   IS
      CURSOR utp_cur
      IS
         SELECT ut.utp_id
           FROM ut_outcome oc, ut_testcase tc, ut_unittest ut
          WHERE tc.id = oc.testcase_id
            AND tc.unittest_id = ut.id
            AND oc.id = outcome_id_in;

      utp_rec   utp_cur%ROWTYPE;
   BEGIN
      OPEN utp_cur;
      FETCH utp_cur INTO utp_rec;
      CLOSE utp_cur;
      RETURN utp_rec.utp_id;
   END;

   FUNCTION unittest (outcome_id_in IN ut_outcome.id%TYPE)
      RETURN ut_unittest.id%TYPE
   IS
      CURSOR unittest_cur
      IS
         SELECT tc.unittest_id
           FROM ut_outcome oc, ut_testcase tc
          WHERE tc.id = oc.testcase_id
            AND oc.id = outcome_id_in;

      unittest_rec   unittest_cur%ROWTYPE;
   BEGIN
      OPEN unittest_cur;
      FETCH unittest_cur INTO unittest_rec;
      CLOSE unittest_cur;
      RETURN unittest_rec.unittest_id;
   END;
END utoutcome;
/
