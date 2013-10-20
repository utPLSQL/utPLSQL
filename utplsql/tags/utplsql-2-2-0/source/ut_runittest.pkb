/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utrunittest
IS

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
Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   PROCEDURE initiate (
      run_id_in        IN   utr_unittest.run_id%TYPE,
      unittest_id_in   IN   utr_unittest.unittest_id%TYPE,
      start_on_in      IN   DATE := SYSDATE
   )
   IS
      &start_ge_8_1 
      PRAGMA autonomous_transaction;
   &start_ge_8_1
   BEGIN
      utplsql2.set_current_unittest (unittest_id_in);

      INSERT INTO utr_unittest
                  (run_id, unittest_id, start_on)
           VALUES (run_id_in, unittest_id_in, start_on_in);

      &start_ge_8_1 
      COMMIT;
   &start_ge_8_1
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- Run has already been initiated. Ignore...
         NULL;
         &start_ge_8_1 
         ROLLBACK;
      &start_ge_8_1
      WHEN OTHERS
      THEN
         &start_ge_8_1 
         ROLLBACK;
         &start_ge_8_1
         utrerror.ut_report (
            run_id_in,
            unittest_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to initiate unit test for run '
            || run_id_in
            || ' unit test ID '
            || unittest_id_in
         );
   END initiate;

   PROCEDURE terminate (
      run_id_in        IN   utr_unittest.run_id%TYPE,
      unittest_id_in   IN   utr_unittest.unittest_id%TYPE,
      end_on_in        IN   DATE := SYSDATE
   )
   IS
      &start_ge_8_1 
      PRAGMA autonomous_transaction;

      &start_ge_8_1

      CURSOR start_cur
      IS
         SELECT start_on, end_on
           FROM utr_unittest
          WHERE run_id = run_id_in
            AND unittest_id_in = unittest_id;

      rec        start_cur%ROWTYPE;
      l_status   utr_unittest.status%TYPE
                     := utresult2.unittest_status (run_id_in, unittest_id_in);
   BEGIN
      OPEN start_cur;
      FETCH start_cur INTO rec;

      IF      start_cur%FOUND
          AND rec.end_on IS NULL
      THEN
         UPDATE utr_unittest
            SET end_on = end_on_in,
                status = l_status
          WHERE run_id = run_id_in
            AND unittest_id_in = unittest_id;
      ELSIF      start_cur%FOUND
             AND rec.end_on IS NOT NULL
      THEN
         -- Run is already terminated. Ignore...
         NULL;
      ELSE
         INSERT INTO utr_unittest
                     (run_id, unittest_id, status, start_on,
                      end_on)
              VALUES (run_id_in, unittest_id_in, l_status, SYSDATE,
                      end_on_in);
      END IF;

      CLOSE start_cur;
      &start_ge_8_1 
      COMMIT;
   &start_ge_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         &start_ge_8_1 
         ROLLBACK;
         &start_ge_8_1
         utrerror.ut_report (
            run_id_in,
            unittest_id_in,
            SQLCODE,
            SQLERRM,
               'Unable to insert or update the utr_unittest table for run '
            || run_id_in
            || ' outcome ID '
            || unittest_id_in
         );
   END terminate;
END utrunittest;
/
