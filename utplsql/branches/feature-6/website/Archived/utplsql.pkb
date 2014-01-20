/* Formatted by PL/Formatter v3.1.2.1 on 2000/09/29 07:46 */

CREATE OR REPLACE PACKAGE BODY utplsql
IS
   g_trc BOOLEAN := FALSE;
   g_version VARCHAR2 (100) := '1.5.2';
   g_config ut_config%ROWTYPE;
   tests test_tt;
   testpkg test_rt;

   -- Start utility definitions

   PROCEDURE pl (
      str IN VARCHAR2,
      len IN INTEGER := 80,
      expand_in IN BOOLEAN := TRUE
   )
   IS
      v_len PLS_INTEGER := LEAST (len, 255);
      v_str VARCHAR2 (2000);
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         pl (SUBSTR (str, len + 1), v_len, expand_in);
      ELSE
         v_str := str;
         DBMS_OUTPUT.put_line (v_str);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF expand_in
         THEN
            DBMS_OUTPUT.enable (1000000);
         ELSE
            RAISE;
         END IF;

         DBMS_OUTPUT.put_line (v_str);
   END;

   FUNCTION vc2bool (vc IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF vc = c_yes
      THEN
         RETURN TRUE;
      ELSIF vc = c_no
      THEN
         RETURN FALSE;
      ELSE
         RETURN NULL;
      END IF;
   END;

   FUNCTION bool2vc (bool IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF bool
      THEN
         RETURN c_yes;
      ELSIF NOT bool
      THEN
         RETURN c_no;
      ELSE
         RETURN 'NULL';
      END IF;
   END;

   PROCEDURE bpl (bool IN BOOLEAN)
   IS
   BEGIN
      pl (bool2vc (bool));
   END;

   FUNCTION ispackage (prog IN VARCHAR2)
      RETURN BOOLEAN
   IS
      /* variables to hold components of the name */
      sch VARCHAR2 (100);
      part1 VARCHAR2 (100);
      part2 VARCHAR2 (100);
      dblink VARCHAR2 (100);
      part1_type NUMBER;
      object_number NUMBER;
   BEGIN
      /* Break down the name into its components */
      DBMS_UTILITY.name_resolve (prog,
         1,
         sch,
         part1,
         part2,
         dblink,
         part1_type,
         object_number
      );
      RETURN part1_type = 9;
   END;

   -- End utility definitions

   PROCEDURE setcurrcase (indx_in IN PLS_INTEGER)
   IS
   BEGIN
      currcase.pkg := testpkg.pkg;
      currcase.prefix := testpkg.prefix;
      currcase.name := tests (indx_in).name;
      currcase.indx := indx_in;
   END;

   FUNCTION pkgname (
      package_in IN VARCHAR2,
      samepackage_in IN BOOLEAN,
      prefix_in IN VARCHAR2,
      ispkg_in IN BOOLEAN
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT ispkg_in
      THEN
         RETURN prefix_in || package_in;
      ELSIF samepackage_in
      THEN
         RETURN package_in;
      ELSE
         RETURN prefix_in || package_in;
      END IF;
   END;

   FUNCTION do_register
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (NVL (g_config.registertest, c_yes) != c_no);
   END;

   FUNCTION progname (
      program_in IN VARCHAR2,
      samepackage_in IN BOOLEAN,
      prefix_in IN VARCHAR2,
      ispkg_in IN BOOLEAN
   )
      RETURN VARCHAR2
   IS
      -- The default setting...
      retval VARCHAR2(1000) := prefix_in || program_in;
   BEGIN
      -- 1.3.5 If not using setup to register then prefix
      -- is already a part of the name; no construction necessary.
      IF NOT do_register
      THEN
         IF UPPER (program_in) NOT IN (c_setup, c_teardown)
         THEN
            retval :=program_in;
         END IF;
      ELSIF NOT ispkg_in
      THEN
         retval :=prefix_in || program_in;
      ELSIF samepackage_in
      THEN
         retval :=prefix_in || program_in;
      ELSE
         -- Ignore prefix only for separate test packages of packaged
         -- functionality.
         retval :=program_in;
      END IF;
      
      RETURN retval;
   END;

   FUNCTION pkgname (
      package_in IN VARCHAR2,
      samepackage_in IN BOOLEAN,
      prefix_in IN VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      utassert.this ('Pkgname: the package record has not been set!',
         testpkg.pkg IS NOT NULL,
         register_in => FALSE
      );
      RETURN pkgname (package_in,
                samepackage_in,
                prefix_in,
                testpkg.ispkg
             );
   END;

   FUNCTION progname (
      program_in IN VARCHAR2,
      samepackage_in IN BOOLEAN,
      prefix_in IN VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      utassert.this ('Progname: the package record has not been set!',
         testpkg.pkg IS NOT NULL,
         register_in => FALSE
      );
      RETURN progname (program_in,
                samepackage_in,
                prefix_in,
                testpkg.ispkg
             );
   END;

   PROCEDURE runprog (
      NAME_IN IN VARCHAR2,
      propagate_in IN BOOLEAN := FALSE
   )
   IS
      v_pkg VARCHAR2 (100)
            := pkgname (testpkg.pkg, testpkg.samepkg, testpkg.prefix);
      v_name VARCHAR2 (100)
               := progname (NAME_IN, testpkg.samepkg, testpkg.prefix);
      v_str VARCHAR2 (32767);
      &start73 
      fdbk PLS_INTEGER; 
      cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR; 
      &end73
   BEGIN
      IF tracing
      THEN
         pl ('Runprog of ' || NAME_IN);
         pl ('   Package and program = ' || v_pkg || '.' || v_name);
         pl ('   Same package? ' || bool2vc (testpkg.samepkg));
         pl ('   Is package? ' || bool2vc (testpkg.ispkg));
         pl ('   Prefix = ' || testpkg.prefix);
      END IF;

      v_str := 'BEGIN ' || v_pkg || '.' || v_name || ';  END;';
      
      &start81
      EXECUTE IMMEDIATE v_str;
      &end81
      &start73
      DBMS_SQL.PARSE (cur, v_str, DBMS_SQL.NATIVE);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.CLOSE_CURSOR (cur);
      &end73
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.CLOSE_CURSOR (cur);
         &end73
         
         IF tracing
         THEN
            pl ('Compile Error "' || SQLERRM || '" on: ');
            pl (v_str);
         END IF;
         
         utAssert.this (
            'Unable to run ' || v_pkg || '.' || v_name || ': ' ||
            SQLERRM,
            FALSE,
            null_ok_in => NULL,
            raise_exc_in => propagate_in,
            register_in => TRUE);
   END;

   PROCEDURE runit (indx_in IN PLS_INTEGER)
   IS
   BEGIN
      setcurrcase (indx_in);
      runprog (tests (indx_in).name, FALSE);
   END;

   PROCEDURE init (prefix_in IN VARCHAR2 := NULL,
      dir_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      tests.delete;
      utresult.init;
      currcase := NULL;
      testpkg := NULL;
      
      IF prefix_in IS NOT NULL AND 
         (prefix_in != g_config.prefix OR g_config.prefix IS NULL)
      THEN
         setprefix (prefix_in);
      END IF;
      
      IF dir_in IS NOT NULL AND dir_in != g_config.directory
      THEN
         setdir (dir_in);
      END IF;
      
   END;

   PROCEDURE compile (file_in IN VARCHAR2, dir_in IN VARCHAR2)
   IS
      fid UTL_FILE.file_type;
      v_dir VARCHAR2 (2000) := NVL (dir_in, dir);
      lines DBMS_SQL.varchar2s;
      cur PLS_INTEGER := DBMS_SQL.open_cursor;

      PROCEDURE recngo (str IN VARCHAR2)
      IS
      BEGIN
         UTL_FILE.fclose (fid);
         DBMS_OUTPUT.put_line ('Error compiling ' || file_in ||
                                  ' located in "' ||
                                  v_dir ||
                                  '": ' ||
                                  str
         );
         DBMS_OUTPUT.put_line ('   Please make sure the directory for utPLSQL is set by calling ' ||
                                  'utPLSQL.setdir.'
         );
         DBMS_OUTPUT.put_line ('   Your test package must reside in this directory.'
         );

         IF DBMS_SQL.is_open (cur)
         THEN
            DBMS_SQL.close_cursor (cur);
         END IF;
      END;
   BEGIN
      utassert.this ('Compile error: you must specify a directory with utPLSQL.setdir!',
         v_dir IS NOT NULL,
         register_in => FALSE
      );
      fid :=
           UTL_FILE.fopen (v_dir, file_in, 'R' 
              &start81 , max_linesize => 32767 &end81);

      LOOP
         BEGIN
            UTL_FILE.get_line (fid, lines (NVL (lines.LAST, 0) + 1));
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               EXIT;
         END;
      END LOOP;

      /* Clean up termination character. */
      LOOP
         IF    lines (lines.LAST) = '/'
            OR RTRIM (lines (lines.LAST)) IS NULL
         THEN
            lines.delete (lines.LAST);
         ELSE
            EXIT;
         END IF;
      END LOOP;

      UTL_FILE.fclose (fid);
      DBMS_SQL.parse (cur,
         lines,
         lines.FIRST,
         lines.LAST,
         TRUE,
         DBMS_SQL.native
      );
      DBMS_SQL.close_cursor (cur);
   EXCEPTION
      WHEN UTL_FILE.invalid_path
      THEN
         recngo ('invalid_path');
      WHEN UTL_FILE.invalid_mode
      THEN
         recngo ('invalid_mode');
      WHEN UTL_FILE.invalid_filehandle
      THEN
         recngo ('invalid_filehandle');
      WHEN UTL_FILE.invalid_operation
      THEN
         recngo ('invalid_operation');
      WHEN UTL_FILE.read_error
      THEN
         recngo ('read_error');
      WHEN UTL_FILE.write_error
      THEN
         recngo ('write_error');
      WHEN UTL_FILE.internal_error
      THEN
         recngo ('internal_error');
      WHEN OTHERS
      THEN
         recngo (SQLERRM);
   END;

   /* Programs used in ut_PKG.setup */

   PROCEDURE setpkg (
      package_in IN VARCHAR2,
      samepackage_in IN BOOLEAN := FALSE,
      prefix_in IN VARCHAR2 := NULL,
      owner_in IN VARCHAR2 := NULL
   )
   IS
      v_pkg VARCHAR2 (1000);
   BEGIN
      testpkg.pkg := package_in;
      testpkg.ispkg := ispackage (package_in);
      testpkg.samepkg := samepackage_in;
      testpkg.prefix := NVL (prefix_in, prefix (owner_in));
      v_pkg := pkgname (testpkg.pkg, testpkg.samepkg, testpkg.prefix);

      -- 1.3.5
      IF NOT do_register
      THEN
         -- Populate test information from ALL_ARGUMENTS
         FOR rec IN (SELECT DISTINCT object_name
                       FROM all_arguments
                      WHERE owner = NVL (UPPER (owner_in), USER)
                        AND package_name = UPPER (v_pkg)
                        AND object_name LIKE
                               UPPER (prefix_in) || '%'
                        AND object_name NOT IN (
                                                  prefix_in ||
                                                     c_setup,
                                                  prefix_in ||
                                                     c_teardown
                                               ))
         LOOP
            addtest (
               testpkg.pkg,
               rec.object_name,
               prefix_in,
               iterations_in => 1,
               override_in => TRUE
            );
         END LOOP;
      END IF;
   END;

   FUNCTION currpkg
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN testpkg.pkg;
   END;

   PROCEDURE addtest (
      package_in IN VARCHAR2,
      NAME_IN IN VARCHAR2,
      prefix_in IN VARCHAR2,
      iterations_in IN PLS_INTEGER,
      override_in IN BOOLEAN
   )
   IS
      indx PLS_INTEGER := NVL (tests.LAST, 0) + 1;
   BEGIN
      -- 1.3.5 Disable calls to addtest from setup.
      IF    do_register
         OR (    NOT do_register
             AND override_in)
      THEN
         IF tracing
         THEN
            pl ('Addtest');
            pl ('   Package and program = ' || package_in || '.' || NAME_IN);
            pl ('   Same package? ' || bool2vc (testpkg.samepkg));
            pl ('   Override? ' || bool2vc (override_in));
            pl ('   Prefix = ' || prefix_in);
         END IF;
         
         tests (indx).pkg := package_in;
         tests (indx).prefix := prefix_in;
         tests (indx).name := NAME_IN;
         tests (indx).iterations := iterations_in;
      END IF;
   END;

   PROCEDURE addtest (
      NAME_IN IN VARCHAR2,
      prefix_in IN VARCHAR2 := NULL,
      iterations_in IN PLS_INTEGER := 1,
      override_in IN BOOLEAN := FALSE
   )
   IS
      indx PLS_INTEGER := NVL (tests.LAST, 0) + 1;
   BEGIN
      addtest (
         testpkg.pkg,
         NAME_IN,
         prefix_in,
         iterations_in,
         override_in
      );
   END;

   /* Test engine */

   FUNCTION do_recompile (recomp IN BOOLEAN)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    recomp
              AND (NVL (g_config.autocompile, c_yes) != c_no));
   END;

   PROCEDURE test (
      package_in IN VARCHAR2,
      samepackage_in IN BOOLEAN := FALSE,
      prefix_in IN VARCHAR2 := NULL,
      recompile_in IN BOOLEAN := TRUE,
      dir_in IN VARCHAR2 := NULL,
      suite_in IN VARCHAR2 := NULL,
      owner_in IN VARCHAR2 := NULL,
      reset_results_in IN BOOLEAN := TRUE
   )
   IS
      indx PLS_INTEGER;
      v_pkg VARCHAR2 (100);
      v_start DATE := SYSDATE;
      v_prefix ut_config.prefix%TYPE := NVL (prefix_in, prefix (owner_in));

      PROCEDURE cleanup IS
      BEGIN
         utresult.show;
         runprog (c_teardown, TRUE);
         
         utpackage.upd (suite_in,
            package_in,
            v_start,
            SYSDATE,
            utresult.success,
            owner_in
         );

         IF reset_results_in
         THEN
            init;
         END IF;
      END;
      
   BEGIN
      init (v_prefix, dir_in);
      
      setpkg (package_in, samepackage_in, v_prefix, owner_in);
      v_pkg := pkgname (package_in, samepackage_in, v_prefix);

      IF do_recompile (recompile_in)
      THEN
         IF tracing
         THEN
            pl ('Recompiling ' || v_pkg || ' in ' || dir_in);
         END IF;

         compile (v_pkg || '.pks', dir_in);
         compile (v_pkg || '.pkb', dir_in);
      END IF;

      runprog (c_setup, TRUE);
      indx := tests.FIRST;

      LOOP
         EXIT WHEN indx IS NULL;
         runit (indx);
         indx := tests.NEXT (indx);
      END LOOP;

      cleanup;
      
   EXCEPTION
      WHEN OTHERS
      THEN
         cleanup;
   END;

   PROCEDURE testsuite (
      suite_in IN VARCHAR2,
      recompile_in IN BOOLEAN := TRUE,
      reset_results_in IN BOOLEAN := TRUE
   )
   IS
      v_suite ut_suite.id%TYPE := utsuite.id_from_name (suite_in);
      v_success BOOLEAN := TRUE;
      v_suite_start DATE := SYSDATE;
      v_pkg_start DATE;
   BEGIN
      FOR rec IN (SELECT *
                    FROM ut_package
                   WHERE suite_id = v_suite
                   ORDER BY seq)
      LOOP
         v_pkg_start := SYSDATE;
         test (rec.name,
            vc2bool (rec.samepackage),
            rec.prefix,
            recompile_in,
            rec.dir,
            v_suite,                                         -- 1.2.7
            rec.owner,                                       -- 1.2.7
            reset_results_in => FALSE                        -- 1.3.1
         );

         IF utresult.failure
         THEN
            v_success := FALSE;
         END IF;
      END LOOP;

      utsuite.upd (v_suite, v_suite_start, SYSDATE, v_success);

      IF reset_results_in
      THEN
         init;
      END IF;
   END;

   /* Programs used in individual unit test programs. */

   PROCEDURE setcase (case_in IN VARCHAR2)
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE setdata (
      dir_in IN VARCHAR2,
      file_in IN VARCHAR2,
      delim_in IN VARCHAR2 := ','
   )
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE passdata (data_in IN VARCHAR2, delim_in IN VARCHAR2 := ',')
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE trc
   IS
   BEGIN
      g_trc := TRUE;
   END;

   PROCEDURE notrc
   IS
   BEGIN
      g_trc := FALSE;
   END;

   FUNCTION tracing
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_trc;
   END;

   FUNCTION version
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_version;
   END;

   FUNCTION seqval (tab_in IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
      sqlstr VARCHAR2(200) := 
         'SELECT ' || tab_in || '_seq.NEXTVAL FROM dual';
      fdbk PLS_INTEGER;
      retval PLS_INTEGER;
   BEGIN
      &start81
      EXECUTE IMMEDIATE sqlstr INTO retval;
      &end81
      &start73
      DECLARE
         fdbk PLS_INTEGER;
         cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
      BEGIN
         DBMS_SQL.PARSE (cur, sqlstr, DBMS_SQL.NATIVE);
         DBMS_SQL.DEFINE_COLUMN (cur, 1, retval);
         fdbk := DBMS_SQL.EXECUTE_AND_FETCH (cur);
         DBMS_SQL.COLUMN_VALUE (cur, 1, retval);
         DBMS_SQL.CLOSE_CURSOR (cur);
      EXCEPTION
         WHEN OTHERS THEN 
            DBMS_SQL.CLOSE_CURSOR (cur); 
            RAISE;
      END;
      &end73
      RETURN retval;
   END;

   -- User configuration 

   PROCEDURE setconfig (
      schema_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      SELECT *
        INTO g_config
        FROM ut_config
       WHERE username = NVL (UPPER (schema_in), USER);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         g_config := NULL;
   END;

   PROCEDURE setprefix (prefix_in IN VARCHAR2, username_in IN VARCHAR2 := NULL)
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      INSERT INTO ut_config
                  (username, prefix)
           VALUES (v_user, prefix_in);

      &start81 COMMIT; &end81
      setconfig (v_user);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE ut_config
            SET prefix = prefix_in
          WHERE username = v_user;

         &start81 COMMIT; &end81
         setconfig (v_user);
      WHEN OTHERS
      THEN
         pl (SQLERRM);
         &start81 ROLLBACK; &end81
   END;

   FUNCTION prefix (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      retval ut_config.prefix%TYPE;
      rec ut_config%ROWTYPE;
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      IF USER = v_user
      THEN
         RETURN NVL (g_config.prefix, c_prefix);
      ELSE
         SELECT *
           INTO rec
           FROM ut_config
          WHERE username = v_user;
         RETURN g_config.prefix;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN c_prefix;
         
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE setdir (dir_in IN VARCHAR2, username_in IN VARCHAR2 := NULL)
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      INSERT INTO ut_config
                  (username, directory)
           VALUES (v_user, dir_in);

      &start81 COMMIT; &end81
      setconfig (v_user);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE ut_config
            SET directory = dir_in
          WHERE username = v_user;

         &start81 COMMIT; &end81
         setconfig (v_user);
      WHEN OTHERS
      THEN
         pl (SQLERRM);
         &start81 ROLLBACK; &end81
   END;

   FUNCTION dir (username_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2
   IS
      retval ut_config.directory%TYPE;
      rec ut_config%ROWTYPE;
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      IF USER = v_user
      THEN
         RETURN g_config.directory;
      ELSE
         SELECT *
           INTO rec
           FROM ut_config
          WHERE username = v_user;
         RETURN g_config.directory;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE autocompile (
      onoff_in IN BOOLEAN,
      username_in IN VARCHAR2 := NULL
   )
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_autocompile CHAR (1) := bool2vc (onoff_in);
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      INSERT INTO ut_config
                  (username, autocompile)
           VALUES (v_user, v_autocompile);

      &start81 COMMIT; &end81
      setconfig (v_user);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE ut_config
            SET autocompile = v_autocompile
          WHERE username = v_user;

         &start81 COMMIT; &end81
         setconfig (v_user);
      WHEN OTHERS
      THEN
         pl (SQLERRM);
         &start81 ROLLBACK; &end81
   END;

   FUNCTION autocompiling (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      retval BOOLEAN;
      rec ut_config%ROWTYPE;
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      IF USER = v_user
      THEN
         RETURN vc2bool (g_config.autocompile);
      ELSE
         SELECT *
           INTO rec
           FROM ut_config
          WHERE username = v_user;
         RETURN vc2bool (rec.autocompile);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   PROCEDURE registertest (
      onoff_in IN BOOLEAN,
      username_in IN VARCHAR2 := NULL
   )
   IS
      &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
      v_registertest CHAR (1) := bool2vc (onoff_in);
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      INSERT INTO ut_config
                  (username, registertest)
           VALUES (v_user, v_registertest);

      &start81 COMMIT; &end81
      setconfig (v_user);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         UPDATE ut_config
            SET registertest = v_registertest
          WHERE username = v_user;

         &start81 COMMIT; &end81
         setconfig (v_user);
      WHEN OTHERS
      THEN
         pl (SQLERRM);
         &start81 ROLLBACK; &end81
   END;

   FUNCTION registeringtest (username_in IN VARCHAR2 := NULL)
      RETURN BOOLEAN
   IS
      retval BOOLEAN;
      rec ut_config%ROWTYPE;
      v_user VARCHAR2 (100) := NVL (UPPER (username_in), USER);
   BEGIN
      IF USER = v_user
      THEN
         RETURN vc2bool (g_config.registertest);
      ELSE
         SELECT *
           INTO rec
           FROM ut_config
          WHERE username = v_user;
         RETURN vc2bool (rec.registertest);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   PROCEDURE showconfig (username_in IN VARCHAR2 := NULL)
   IS
      v_schema VARCHAR2(100) := NVL (UPPER (username_in), USER);
      v_config ut_config%ROWTYPE;
   BEGIN
      BEGIN
         SELECT *
           INTO v_config
           FROM ut_config
          WHERE username = v_schema;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_config := NULL;
      END;
      
      pl ('=============================================================');
      pl ('utPLSQL Configuration for ' || v_schema);
      pl ('   Directory: ' || v_config.directory);
      pl ('   Autcompile? ' || v_config.autocompile);
      pl ('   Manual test registration? ' || v_config.registertest);
      pl ('   Prefix = ' || v_config.prefix);
      pl ('=============================================================');
   END;
   
BEGIN
   setconfig;
END;
/
SHO ERR 
REM exec plvvu.err  ('b:utplsql');
