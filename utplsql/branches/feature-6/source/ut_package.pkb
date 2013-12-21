/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utpackage
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
Revision 1.5  2004/11/23 14:56:47  chrisrimmer
Moved dbms_pipe code into its own package.  Also changed some preprocessor flags

Revision 1.4  2004/11/16 09:46:49  chrisrimmer
Changed to new version detection system.

Revision 1.3  2004/07/14 17:01:57  chrisrimmer
Added first version of pluggable reporter packages

Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   FUNCTION name_from_id (id_in IN ut_package.id%TYPE)
      RETURN ut_package.name%TYPE
   IS
      retval   ut_package.name%TYPE;
   BEGIN
      SELECT name
        INTO retval
        FROM ut_package
       WHERE id = id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   -- Need to add owner to param list and query 
   FUNCTION id_from_name (name_in IN ut_package.name%TYPE,
       owner_in		  IN ut_package.owner%TYPE := NULL)
      RETURN ut_package.id%TYPE
   IS
      retval   ut_package.id%TYPE;
      v_owner ut_package.owner%type := nvl(owner_in,USER);
   BEGIN
      SELECT id
        INTO retval
        FROM ut_package
       WHERE name = UPPER (name_in)
         AND owner=v_owner
	 AND SUITE_ID is null;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   PROCEDURE ADD (
      suite_in            IN   INTEGER,
      package_in          IN   VARCHAR2,
      samepackage_in      IN   BOOLEAN := FALSE,
      prefix_in           IN   VARCHAR2 := NULL,
      dir_in              IN   VARCHAR2 := NULL,
      seq_in              IN   PLS_INTEGER := NULL,
      owner_in            IN   VARCHAR2 := NULL,
      add_tests_in        IN   BOOLEAN := FALSE,
      test_overloads_in   IN   BOOLEAN := FALSE
   )
   IS
      &start_ge_8_1 PRAGMA AUTONOMOUS_TRANSACTION; &end_ge_8_1
      v_owner    VARCHAR2 (30)                 := NVL (owner_in, USER);
      v_id       ut_package.id%TYPE;
      v_same     ut_package.samepackage%TYPE   := utplsql.c_yes;
      v_prefix   ut_config.prefix%TYPE
                               := NVL (prefix_in, utconfig.prefix (owner_in));
   BEGIN
      IF NOT (NVL (samepackage_in, FALSE))
      THEN
         v_same := utplsql.c_no;
      END IF;

      &start_ge_8_1 v_id := utplsql.seqval ('ut_package'); &end_ge_8_1
      &start_lt_8_1 SELECT ut_package_seq.NEXTVAL INTO v_id FROM dual; &end_lt_8_1

      INSERT INTO ut_package
                  (id, suite_id, name,
                   owner, samepackage, prefix, dir, seq,
                   executions, failures)
           VALUES (v_id, suite_in, UPPER (package_in),
                   UPPER (v_owner), v_same, v_prefix, dir_in, NVL (seq_in, 1),
                   0, 0);
      IF id_from_name( UPPER (package_in),owner_in) IS NULL 
      THEN
         &start_ge_8_1 v_id := utplsql.seqval ('ut_package'); &end_ge_8_1
         &start_lt_8_1 SELECT ut_package_seq.NEXTVAL INTO v_id FROM dual; &end_lt_8_1

         INSERT INTO ut_package
                  (id, suite_id, name,
                   owner, samepackage, prefix, dir, seq,
                   executions, failures)
           VALUES (v_id, NULL, UPPER (package_in),
                   UPPER (v_owner), v_same, v_prefix, dir_in, NVL (seq_in, 1),
                   0, 0);
         

         &start_ge_8_1 COMMIT; &end_ge_8_1
      END IF;
      IF add_tests_in
      THEN
         -- For each program in ALL_ARGUMENTS, add a test.

         &start_ge_8_1 
         -- 8i NDS implementation
         DECLARE
            TYPE cv_t IS REF CURSOR;

            cv         cv_t;
            v_name     VARCHAR2 (100);
            v_query    VARCHAR2 (32767);
            v_suffix   VARCHAR2 (100)   := NULL;
         BEGIN
            IF test_overloads_in
            THEN
               v_suffix := ' || TO_CHAR(overload)';
            END IF;

            v_query :=
                     'SELECT DISTINCT object_name '
                  || v_suffix
                  || ' name '
                  || ' from all_arguments  
                 where owner = :owner and package_name = :package';
            OPEN cv FOR v_query
               USING NVL (UPPER (owner_in), USER), UPPER (package_in);

            LOOP
               FETCH cv INTO v_name;
               EXIT WHEN cv%NOTFOUND;

               IF utplsql.tracing
               THEN
                  utreport.pl (   'Adding test '
                              || package_in
                              || '.'
                              || v_name);
               END IF;

               uttest.ADD (v_id, v_name,    'Test '
                                         || v_name);
            END LOOP;

            CLOSE cv;
         END;

         &end_ge_8_1
         &start_lt_8_1
         -- 7.3 DBMS_SQL Implementation
         DECLARE
            cur        PLS_INTEGER      := DBMS_SQL.open_cursor;
            fdbk       PLS_INTEGER;
            v_name     VARCHAR2 (100);
            v_query    VARCHAR2 (32767);
            v_suffix   VARCHAR2 (100)   := NULL;
         BEGIN
            IF test_overloads_in
            THEN
               v_suffix := ' || TO_CHAR(overload)';
            END IF;

            v_query :=
                     'SELECT DISTINCT object_name '
                  || v_suffix
                  || ' name '
                  || ' from all_arguments  
                 where owner = :owner and package_name = :package';
            DBMS_SQL.parse (cur, v_query, DBMS_SQL.native);
            DBMS_SQL.bind_variable (cur, 'owner', NVL (UPPER (owner_in), USER));
            DBMS_SQL.bind_variable (cur, 'package', UPPER (package_in));
            fdbk := DBMS_SQL.EXECUTE (cur);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows (cur) = 0;
               DBMS_SQL.column_value (cur, 1, v_name);

               IF utplsql.tracing
               THEN
                  utreport.pl (   'Adding test '
                              || package_in
                              || '.'
                              || v_name);
               END IF;

               uttest.ADD (v_id, v_name,    'Test '
                                         || v_name);
            END LOOP;

            DBMS_SQL.close_cursor (cur);
         END;
      &end_lt_8_1
      END IF;
   &start_ge_8_1 COMMIT; &end_ge_8_1
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- Update changeable columns.
         UPDATE ut_package
            SET samepackage = v_same,
                prefix = v_prefix,
                dir = dir_in
          WHERE owner = UPPER (v_owner)
            AND name = UPPER (package_in)
            AND suite_id = suite_in;
      &start_ge_8_1 COMMIT; &end_ge_8_1

      WHEN OTHERS
      THEN
         utreport.pl (   'Add package error: '
                     || SQLERRM);
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
         RAISE;
   END;

   PROCEDURE ADD (
      suite_in            IN   VARCHAR2,
      package_in          IN   VARCHAR2,
      samepackage_in      IN   BOOLEAN := FALSE,
      prefix_in           IN   VARCHAR2 := NULL,
      dir_in              IN   VARCHAR2 := NULL,
      seq_in              IN   PLS_INTEGER := NULL,
      owner_in            IN   VARCHAR2 := NULL,
      add_tests_in        IN   BOOLEAN := FALSE,
      test_overloads_in   IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      ADD (
         utsuite.id_from_name (suite_in),
         package_in,
         samepackage_in,
         prefix_in,
         dir_in,
         seq_in,
         owner_in,
         add_tests_in,
         test_overloads_in
      );
   END;

   PROCEDURE rem (
      suite_in     IN   INTEGER,
      package_in   IN   VARCHAR2,
      owner_in     IN   VARCHAR2 := NULL
   )
   IS
   &start_ge_8_1 PRAGMA AUTONOMOUS_TRANSACTION; &end_ge_8_1
   BEGIN
      DELETE FROM ut_package
            WHERE (   suite_id = UPPER (suite_in)
                   OR (    suite_id IS NULL
                       AND suite_in IS NULL
                      )
                  )
              AND name = UPPER (package_in)
              AND owner = NVL (UPPER (owner_in), USER);
   &start_ge_8_1 COMMIT; &end_ge_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         utreport.pl (   'Remove package error: '
                     || SQLERRM);
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
         RAISE;
   END;

   PROCEDURE rem (
      suite_in     IN   VARCHAR2,
      package_in   IN   VARCHAR2,
      owner_in     IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      rem (utsuite.id_from_name (suite_in), package_in, owner_in);
   END;

   PROCEDURE upd (
      suite_id_in        IN   INTEGER,
      package_in      IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN,
      owner_in        IN   VARCHAR2 := NULL
   )
   IS
      l_status    VARCHAR2 (100) := utplsql.c_success;
      &start_ge_8_1 PRAGMA AUTONOMOUS_TRANSACTION; &end_ge_8_1
      v_failure   PLS_INTEGER    := 0;

      PROCEDURE do_upd
      IS
      BEGIN
         UPDATE ut_package
            SET last_status = l_status,
                last_start = start_in,
                last_end = end_in,
                executions =   NVL (executions, 0)
                             + 1,
                failures =   NVL (failures, 0)
                           + v_failure
                ,last_run_id = utplsql2.runnum -- 2.0.9.1
          WHERE  nvl(suite_id,0) = nvl(suite_id_in,0) 
            AND name = UPPER (package_in)
            AND owner = NVL (UPPER (owner_in), USER);
      END;
   BEGIN
      IF NOT successful_in
      THEN
         v_failure := 1;
         l_status := utplsql.c_failure;
      END IF;

      do_upd;

      IF SQL%ROWCOUNT = 0
      THEN
         ADD (
            suite_id_in,
            package_in,
            samepackage_in=> FALSE,
            prefix_in=> utconfig.prefix (owner_in),
            dir_in=> NULL,
            seq_in=> NULL,
            owner_in=> owner_in,
            add_tests_in=> FALSE,
            test_overloads_in=> FALSE
         );
         do_upd;
      END IF;
   &start_ge_8_1 COMMIT; &end_ge_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         utreport.pl (   'Update package error: '
                     || SQLERRM);
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
         RAISE;
   END;

   PROCEDURE upd (
      suite_in        IN   VARCHAR2,
      package_in      IN   VARCHAR2,
      start_in             DATE,
      end_in               DATE,
      successful_in        BOOLEAN,
      owner_in        IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      upd (
         utsuite.id_from_name (suite_in),
         package_in,
         start_in,
         end_in,
         successful_in,
         owner_in
      );
   END;
END utpackage;
/
