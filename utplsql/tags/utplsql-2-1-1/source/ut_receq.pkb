-- register tables and view that will have record comparison functions created

-- 26 Dec 2001  Dan Spencer   Created

-- 31 Jul 2002  Chris Rimmer  Fixed so that records in foreign schemas work



CREATE OR REPLACE PACKAGE BODY utreceq
IS 
   PROCEDURE delete_receq (id_in ut_receq.id%TYPE)
   IS 
      v_cur     PLS_INTEGER     := DBMS_SQL.open_cursor;
      sql_str   VARCHAR2 (2000);
      v_cnt     PLS_INTEGER;
   BEGIN
      SELECT COUNT (*)
        INTO v_cnt
        FROM ut_receq_pkg
       WHERE receq_id = id_in AND created_by = USER;

      IF v_cnt < 1
      THEN
         SELECT 'DROP FUNCTION ' || test_name
           INTO sql_str
           FROM ut_receq
          WHERE id = id_in AND created_by = USER;

         DBMS_SQL.parse (v_cur, sql_str, DBMS_SQL.native);
         DBMS_SQL.close_cursor (v_cur);
      END IF;

      DELETE FROM ut_receq
            WHERE id = id_in AND created_by = USER;
   EXCEPTION
      WHEN OTHERS
      THEN
         utplsql.pl (SQLERRM);
         DBMS_SQL.close_cursor (v_cur);
         utplsql.pl (
            'Delete failed - function probably used by another package'
         );
   END;

   FUNCTION id_from_name (
      NAME_IN    IN   ut_receq.NAME%TYPE,
      owner_in   IN   ut_receq.rec_owner%TYPE := USER
   )
      RETURN INTEGER
   IS 
      retval   INTEGER;
   BEGIN
      SELECT id
        INTO retval
        FROM ut_receq
       WHERE NAME = UPPER (NAME_IN)
         AND rec_owner = UPPER (owner_in)
         AND created_by = USER;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END id_from_name;

   FUNCTION name_from_id (id_in IN ut_receq.id%TYPE)
      RETURN VARCHAR2
   IS 
      retval   VARCHAR2 (30);
   BEGIN
      SELECT NAME
        INTO retval
        FROM ut_receq
       WHERE id = id_in;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END name_from_id;

   FUNCTION receq_name (
      NAME_IN        IN   VARCHAR2,
      owner_in       IN   VARCHAR2 DEFAULT USER,
      test_name_in   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS 
      retval     VARCHAR2 (30);
      func_len   INTEGER;
   BEGIN
      IF test_name_in IS NOT NULL
      THEN
         retval := UPPER (test_name_in);
      ELSE
         retval := 'eq_';

         IF owner_in <> USER
         THEN
            retval := retval || owner_in || '_';
         END IF;

         retval := retval || NAME_IN;
      END IF;

      RETURN UPPER (retval);
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         utplsql.pl ('Generated test name is too long');
         utplsql.pl (
            'Resubmit with a defined test_name_in=>''EQ_your_name'''
         );
         RETURN NULL;
   END receq_name;

   PROCEDURE COMPILE (receq_id_in IN ut_receq.id%TYPE)
   IS 
      lines      DBMS_SQL.varchar2s;
      cur        PLS_INTEGER               := DBMS_SQL.open_cursor;
      v_rec      ut_receq%ROWTYPE;
      v_schema   ut_receq.rec_owner%TYPE;
   BEGIN
      lines.DELETE;

      SELECT *
        INTO v_rec
        FROM ut_receq
       WHERE id = receq_id_in AND created_by = USER;

      IF v_rec.rec_owner <> USER
      THEN
         v_schema := v_rec.rec_owner || '.';
      END IF;

      lines (1) := 'CREATE OR REPLACE FUNCTION ' || v_rec.test_name || '(';
      lines (lines.LAST + 1) := '   a ' || v_schema || v_rec.NAME || '%ROWTYPE , ';
      lines (lines.LAST + 1) := '   b ' || v_schema || v_rec.NAME || '%ROWTYPE ) ';
      lines (lines.LAST + 1) := 'RETURN BOOLEAN ';
      lines (lines.LAST + 1) := 'IS  BEGIN ';
      lines (lines.LAST + 1) := '    RETURN (';

      FOR utc_rec IN (SELECT   *
                          FROM all_tab_columns
                         WHERE table_name = v_rec.NAME
                           AND owner = v_rec.rec_owner
                      ORDER BY column_id)
      LOOP
         IF utc_rec.column_id > 1
         THEN
            lines (lines.LAST + 1) := ' AND ';
         END IF;

         lines (lines.LAST + 1) :=    '( ( a.'
                                   || utc_rec.column_name
                                   || ' IS NULL AND  b.'
                                   || utc_rec.column_name
                                   || ' IS NULL ) OR ';

         IF utc_rec.data_type = 'CLOB'
         THEN
            lines (lines.LAST) :=    lines (lines.LAST)
                                  || 'DBMS_LOB.COMPARE( a.'
                                  || utc_rec.column_name
                                  || ' , b.'
                                  || utc_rec.column_name
                                  || ') = 0 )';
         ELSE
            lines (lines.LAST) :=    lines (lines.LAST)
                                  || 'a.'
                                  || utc_rec.column_name
                                  || ' = b.'
                                  || utc_rec.column_name
                                  || ')';
         END IF;
      END LOOP;

      lines (lines.LAST + 1) := '); END ' || v_rec.test_name || ';';
      DBMS_SQL.parse (
         cur,
         lines,
         lines.FIRST,
         lines.LAST,
         TRUE ,
         DBMS_SQL.native
      );
      DBMS_SQL.close_cursor (cur);
   END COMPILE;
   -- Public Methods

   PROCEDURE ADD (
      pkg_name_in    IN   ut_package.NAME%TYPE,
      record_in      IN   ut_receq.NAME%TYPE,
      rec_owner_in   IN   ut_receq.created_by%TYPE := USER
   )
   IS 
      v_pkg_id     NUMBER;
      v_receq_id   NUMBER;
      v_obj_type   user_objects.object_type%TYPE;
      v_recname    VARCHAR2 (30);
   BEGIN
      v_pkg_id := utpackage.id_from_name (pkg_name_in);
      v_receq_id := id_from_name (record_in);

      IF v_pkg_id IS NULL
      THEN
         utplsql.pl (pkg_name_in || ' does not exist');
      ELSIF v_receq_id IS NULL
      THEN
         SELECT object_type
           INTO v_obj_type
           FROM all_objects
          WHERE object_name = UPPER (record_in)
            AND owner = UPPER (rec_owner_in)
            AND object_type IN ('TABLE', 'VIEW');

         v_receq_id := utplsql.seqval ('ut_receq');
         v_recname := receq_name (record_in, rec_owner_in);

         INSERT INTO ut_receq
              VALUES (v_receq_id, UPPER (record_in), v_recname, USER, UPPER (
                                                                         rec_owner_in
                                                                      ));
      END IF;

      utreceq.COMPILE (v_receq_id);
      utplsql.pl (v_recname || ' compiled for ' || v_obj_type || ' ' || record_in);

      BEGIN
         INSERT INTO ut_receq_pkg
              VALUES (v_receq_id, v_pkg_id, USER);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            utplsql.pl (
               v_recname || ' already registered for package ' || pkg_name_in
            );
      END;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         utplsql.pl (record_in || ' does not exist in schema ' || rec_owner_in);
   END ADD;

   PROCEDURE COMPILE (pkg_name_in IN ut_package.NAME%TYPE)
   IS 
      v_pkg_id   NUMBER;
   BEGIN
      v_pkg_id := utpackage.id_from_name (pkg_name_in);

      FOR j IN (SELECT receq_id
                  FROM ut_receq_pkg
                 WHERE pkg_id = v_pkg_id AND created_by = USER)
      LOOP
         COMPILE (j.receq_id);
      END LOOP;
   END COMPILE;

   PROCEDURE REM (
      NAME_IN          IN   ut_receq.NAME%TYPE,
      rec_owner_in     IN   ut_receq.created_by%TYPE,
      for_package_in   IN   BOOLEAN := FALSE
   )
   IS 
      v_pkg_id     INTEGER;
      v_receq_id   INTEGER;
   BEGIN
      IF for_package_in
      THEN
         v_pkg_id := utpackage.id_from_name (NAME_IN);

         FOR j IN (SELECT receq_id
                     FROM ut_receq_pkg
                    WHERE pkg_id = v_pkg_id)
         LOOP
            DELETE FROM ut_receq_pkg
                  WHERE pkg_id = v_pkg_id
                    AND created_by = USER
                    AND receq_id = j.receq_id;

            delete_receq (v_receq_id);
         END LOOP;
      ELSE
         v_receq_id := utreceq.id_from_name (NAME_IN, rec_owner_in);

         DELETE FROM ut_receq_pkg
               WHERE receq_id = v_receq_id;

         delete_receq (v_receq_id);
      END IF;
   END REM;
END utreceq;
/
