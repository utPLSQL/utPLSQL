/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utoutcome

/************************************************************************
GNU General Public License for utPLSQL

Copyright (C) 2000-2003 
Steven Feuerstein and the utPLSQL Project
(steven@stevenfeuerstein.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program (see license.txt); if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
************************************************************************
$Log$
Revision 1.2  2003/07/01 19:36:46  chrisrimmer
Added Standard Headers

************************************************************************/

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
