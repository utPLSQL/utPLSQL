/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY uttest
IS
   
/*
GNU General Public License for utPLSQL

Copyright (C) 2000 Steven Feuerstein, steven@stevenfeuerstein.com

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
*/

   FUNCTION name_from_id (id_in IN ut_test.id%TYPE)
      RETURN ut_test.name%TYPE
   IS
      retval   ut_test.name%TYPE;
   BEGIN
      SELECT name
        INTO retval
        FROM ut_test
       WHERE id = id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION id_from_name (name_in IN ut_test.name%TYPE)
      RETURN ut_test.id%TYPE
   IS
      retval   ut_test.id%TYPE;
   BEGIN
      SELECT name
        INTO retval
        FROM ut_test
       WHERE name = UPPER (name_in);
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   PROCEDURE ADD (
      package_in   IN   INTEGER,
      test_in      IN   VARCHAR2,
      desc_in      IN   VARCHAR2 := NULL,
      seq_in       IN   PLS_INTEGER := NULL
   )
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_id   ut_test.id%TYPE;
   BEGIN
      &start81 v_id := utplsql.seqval ('ut_test'); &end81
      &start73 SELECT ut_test_seq.NEXTVAL INTO v_id FROM dual; &end73

      INSERT INTO ut_test
                  (id, package_id, name, description,
                   seq)
           VALUES (v_id, package_in, UPPER (test_in), desc_in,
                   NVL (seq_in, 1));
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         utplsql.pl (   'Add test error: '
                     || SQLERRM);
         &start81 ROLLBACK; &end81
         RAISE;
   END;

   PROCEDURE ADD (
      package_in   IN   VARCHAR2,
      test_in      IN   VARCHAR2,
      desc_in      IN   VARCHAR2 := NULL,
      seq_in       IN   PLS_INTEGER := NULL
   )
   IS
   BEGIN
      ADD (utpackage.id_from_name (package_in), test_in, desc_in, seq_in);
   END;

   PROCEDURE rem (package_in IN INTEGER, test_in IN VARCHAR2)
   IS
   &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
   BEGIN
      DELETE FROM ut_test
            WHERE package_id = package_in
              AND name LIKE UPPER (test_in);
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         utplsql.pl (   'Remove test error: '
                     || SQLERRM);
         &start81 ROLLBACK; &end81
         RAISE;
   END;

   PROCEDURE rem (package_in IN VARCHAR2, test_in IN VARCHAR2)
   IS
   BEGIN
      rem (utpackage.id_from_name (package_in), test_in);
   END;

   PROCEDURE upd (
      package_in      IN   INTEGER,
      test_in         IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN
   )
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_failure   PLS_INTEGER := 0;
   BEGIN
      IF NOT successful_in
      THEN
         v_failure := 1;
      END IF;

      UPDATE ut_test
         SET last_start = start_in,
             last_end = end_in,
             executions =   executions
                          + 1,
             failures =   failures
                        + v_failure
       WHERE package_id = package_in
         AND name = UPPER (test_in);
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         utplsql.pl (   'Update test error: '
                     || SQLERRM);
         &start81 ROLLBACK; &end81
         RAISE;
   END;

   PROCEDURE upd (
      package_in      IN   VARCHAR2,
      test_in         IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN
   )
   IS
   BEGIN
      upd (
         utpackage.id_from_name (package_in),
         test_in,
         start_in,
         end_in,
         successful_in
      );
   END;
END uttest;
/
