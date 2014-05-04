/* Formatted on 2002/03/31 23:53 (Formatter Plus v4.5.2) */
CREATE OR REPLACE PACKAGE BODY utplsql
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
Revision 1.7  2004/11/28 20:48:55  chrisrimmer
Incremented version number

Revision 1.6  2004/11/23 14:56:48  chrisrimmer
Moved dbms_pipe code into its own package.  Also changed some preprocessor flags

Revision 1.5  2004/11/16 09:46:49  chrisrimmer
Changed to new version detection system.

Revision 1.4  2004/07/14 17:01:57  chrisrimmer
Added first version of pluggable reporter packages

Revision 1.3  2004/05/11 15:33:57  chrisrimmer
Added 9.2 specific code from Mark Vilrokx

Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   g_trc       BOOLEAN        := FALSE;
   g_version   VARCHAR2 (100) := '2.2.2';

   tests       test_tt;
   testpkg     test_rt;

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

   FUNCTION progexists (
      prog_in   IN   VARCHAR2,
      sch_in    IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_prog          VARCHAR2 (1000) := prog_in;
      /* variables to hold components of the name */
      sch             VARCHAR2 (100);
      part1           VARCHAR2 (100);
      part2           VARCHAR2 (100);
      dblink          VARCHAR2 (100);
      part1_type      NUMBER;
      object_number   NUMBER;
   BEGIN
      IF sch_in IS NOT NULL
      THEN
         v_prog :=    sch_in
                   || '.'
                   || prog_in;
      END IF;
 
      /* Break down the name into its components */
      DBMS_UTILITY.name_resolve (
         v_prog,
         1,
         sch,
         part1,
         part2,
         dblink,
         part1_type,
         object_number
      );
      RETURN TRUE;
   EXCEPTION
      -- Josh Goldie: 2.0.10.3 handle failure for objects.
      WHEN OTHERS
      THEN
         IF sch_in IS NOT NULL
         THEN
            RETURN progexists (prog_in, NULL);
         ELSE
            /* Begin changes to check if v_prog is an object */
            DECLARE
               block   VARCHAR2(100) := 
               'DECLARE obj ' || v_prog || '; BEGIN NULL; END;';
               &start_lt_8_1
               cur     PLS_INTEGER := DBMS_SQL.open_cursor;
               fdbk    PLS_INTEGER;
               &end_lt_8_1
            BEGIN
               &start_ge_8_1
               EXECUTE IMMEDIATE block;
               &start_ge_8_1
              
               &start_lt_8_1
               DBMS_SQL.parse (
                  cur, 
                  block, 
                  DBMS_SQL.native
               );
 
               fdbk := DBMS_SQL.EXECUTE(cur);
              
               DBMS_SQL.close_cursor(cur);
               &end_lt_8_1
              
               RETURN TRUE;
            EXCEPTION
               WHEN OTHERS 
               THEN
                  &start_lt_8_1
                  DBMS_SQL.close_cursor(cur);
                  &end_lt_8_1
                  RETURN FALSE;
            END; 
            /* End changes to check if v_prog is an object */
         END IF;
   END;


   FUNCTION ispackage (
      prog_in   IN   VARCHAR2,
      sch_in    IN   VARCHAR2
   )
      RETURN BOOLEAN
   IS
      v_prog          VARCHAR2 (1000) := prog_in;
      /* variables to hold components of the name */
      sch             VARCHAR2 (100);
      part1           VARCHAR2 (100);
      part2           VARCHAR2 (100);
      dblink          VARCHAR2 (100);
      part1_type      NUMBER;
      object_number   NUMBER;
   BEGIN
      IF sch_in IS NOT NULL
      THEN
         v_prog :=    sch_in
                   || '.'
                   || prog_in;
      END IF;

      /* Break down the name into its components */
      DBMS_UTILITY.name_resolve (
         v_prog,
         1,
         sch,
         part1,
         part2,
         dblink,
         part1_type,
         object_number
      );
      RETURN part1_type = 9;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF sch_in IS NOT NULL
         THEN
            RETURN ispackage (prog_in, NULL);
         ELSE
            RETURN FALSE;
         END IF;
   END;

   -- End utility definitions

   PROCEDURE setcurrcase (indx_in IN PLS_INTEGER)
   IS
   BEGIN
      currcase.pkg := testpkg.pkg;
      currcase.prefix := testpkg.prefix;
      currcase.NAME := tests (indx_in).NAME;
      currcase.indx := indx_in;
   END;

   FUNCTION pkgname (
      package_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
      ispkg_in         IN   BOOLEAN,
      owner_in         IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2
   IS
      retval   VARCHAR2 (1000);
   BEGIN
      -- 2.0.9.1: revamp for owner/remote schema exec.
      IF      NOT ispkg_in
          AND NOT samepackage_in -- 2.0.9.2 add second clause
      THEN
         retval :=    prefix_in
                   || package_in;
      ELSIF samepackage_in
      THEN
         retval := package_in;
      ELSE
         retval :=    prefix_in
                   || package_in;
      END IF;

      IF owner_in IS NOT NULL
      THEN
        -- 2.0.10.2: embed owner_in in double quotes to support
       --           OS authentication 
         retval := '"' || owner_in || '"' 
         --retval :=    owner_in
                   || '.'
                   || retval;
      END IF;

      RETURN retval;
   END;

   /* 1.5.3 No longer in use
   FUNCTION do_register
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (NVL (g_config.registertest, c_yes) != c_no);
   END;
   */

   FUNCTION progname (
      program_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
      ispkg_in         IN   BOOLEAN
   )
      RETURN VARCHAR2
   IS
      -- The default setting...
      retval   VARCHAR2 (1000)
                    :=    prefix_in
                       || program_in;
   BEGIN
      -- 1.3.5 If not using setup to register then prefix
      -- is already a part of the name; no construction necessary.
      IF NOT utconfig.registeringtest
      THEN
         IF UPPER (program_in) NOT IN
                           (c_setup, c_teardown)
         THEN
            retval := program_in;
         END IF;
      ELSIF NOT ispkg_in
      THEN
         retval :=    prefix_in
                   || program_in;
      ELSIF samepackage_in
      THEN
         retval :=    prefix_in
                   || program_in;
      ELSE
         -- Ignore prefix only for separate test packages of packaged
         -- functionality.
         retval := program_in;
      END IF;

      RETURN retval;
   END;

   FUNCTION pkgname (
      package_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2,
      owner_in         IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2
   IS
   BEGIN
      utassert.this (
         'Pkgname: the package record has not been set!',
         testpkg.pkg IS NOT NULL,
         register_in=> FALSE
      );
      RETURN pkgname (
                package_in,
                samepackage_in,
                prefix_in,
                testpkg.ispkg,
                owner_in
             );
   END;

   FUNCTION progname (
      program_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN,
      prefix_in        IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      utassert.this (
         'Progname: the package record has not been set!',
         testpkg.pkg IS NOT NULL,
         register_in=> FALSE
      );
      RETURN progname (
                program_in,
                samepackage_in,
                prefix_in,
                testpkg.ispkg
             );
   END;

   PROCEDURE runprog (
      name_in        IN   VARCHAR2,
      propagate_in   IN   BOOLEAN := FALSE
   )
   IS
      v_pkg    VARCHAR2 (100)
   := pkgname (
         testpkg.pkg,
         testpkg.samepkg,
         testpkg.prefix,
         testpkg.owner
      );
      v_name   VARCHAR2 (100)   := name_in;
      /*
      1.5.3 No longer needed; name is always already prefixed.
               := progname (NAME_IN, testpkg.samepkg, testpkg.prefix);
      */
      v_str    VARCHAR2 (32767);
      &start_lt_8_1 
      fdbk     PLS_INTEGER;
      cur      PLS_INTEGER
                          := DBMS_SQL.open_cursor;
   &end_lt_8_1
   BEGIN
      IF tracing
      THEN
         utreport.pl (   'Runprog of '
             || name_in);
         utreport.pl (
               '   Package and program = '
            || v_pkg
            || '.'
            || v_name
         );
         utreport.pl (
               '   Same package? '
            || bool2vc (testpkg.samepkg)
         );
         utreport.pl (
               '   Is package? '
            || bool2vc (testpkg.ispkg)
         );
         utreport.pl (   '   Prefix = '
             || testpkg.prefix);
      END IF;

      v_str :=    'BEGIN '
               || v_pkg
               || '.'
               || v_name
               || ';  END;';
      &start_ge_8_1
      EXECUTE IMMEDIATE v_str;
      &start_ge_8_1
      &start_lt_8_1
      DBMS_SQL.parse (cur, v_str, DBMS_SQL.native);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.close_cursor (cur);
   &end_lt_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         &start_lt_8_1
         DBMS_SQL.close_cursor (cur);

         &end_lt_8_1

         IF tracing
         THEN
            utreport.pl (
                  'Compile Error "'
               || SQLERRM
               || '" on: '
            );
            utreport.pl (v_str);
         END IF;

         utassert.this (
               'Unable to run '
            || v_pkg
            || '.'
            || v_name
            || ': '
            || SQLERRM,
            FALSE,
            null_ok_in=> NULL,
            raise_exc_in=> propagate_in,
            register_in=> TRUE
         );
   END;

   PROCEDURE runit (
      indx_in               IN   PLS_INTEGER,
      per_method_setup_in   IN   BOOLEAN,
      prefix_in             IN   VARCHAR2
   )
   IS
   BEGIN
      setcurrcase (indx_in);

      IF per_method_setup_in
      THEN
         runprog (   prefix_in
                  || c_setup, TRUE);
      END IF;

      runprog (tests (indx_in).NAME, FALSE);

      IF per_method_setup_in
      THEN
         runprog (
               prefix_in
            || c_teardown,
            TRUE
         );
      END IF;
   END;

   PROCEDURE init_tests
   IS
      nulltest   test_rt;
      nullcase   testcase_rt;
   BEGIN
      tests.DELETE;
      currcase := nullcase;
      testpkg := nulltest;
   END;

   PROCEDURE init (
      prefix_in       IN   VARCHAR2 := NULL,
      dir_in          IN   VARCHAR2 := NULL,
      from_suite_in   IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      init_tests;

      --Removed test for null as utConfig.prefix never returns null 
      IF      prefix_in IS NOT NULL
          AND prefix_in != utconfig.prefix
      THEN
         utconfig.setprefix (prefix_in);
      END IF;

      IF      dir_in IS NOT NULL
          AND (   dir_in != utconfig.dir
               OR utconfig.dir IS NULL
              )
      /* 1.5.3 Check for null config directory as well */
      THEN
         utconfig.setdir (dir_in);
      END IF;

      utresult.init (from_suite_in);
     
      -- 2.0.1 compatibilty with utPLSQL2
      utplsql2.set_runnum;

      IF tracing
      THEN
         utreport.pl ('Initialized utPLSQL session...');
      END IF;
   END;

   PROCEDURE COMPILE (
      file_in   IN   VARCHAR2,
      dir_in    IN   VARCHAR2
   )
   IS
      fid     UTL_FILE.file_type;
      v_dir   VARCHAR2 (2000)
                    := NVL (dir_in, utconfig.dir);
      lines   DBMS_SQL.varchar2s;
      cur     PLS_INTEGER       := DBMS_SQL.open_cursor;

      PROCEDURE recngo (str IN VARCHAR2)
      IS
      BEGIN
         UTL_FILE.fclose (fid);
         utreport.pl (
               'Error compiling '
            || file_in
            || ' located in "'
            || v_dir
            || '": '
            || str
         );
         utreport.pl (
               '   Please make sure the directory for utPLSQL is set by calling '
            || 'utConfig.setdir.'
         );
         utreport.pl (
            '   Your test package must reside in this directory.'
         );

         IF DBMS_SQL.is_open (cur)
         THEN
            DBMS_SQL.close_cursor (cur);
         END IF;
      END;
   BEGIN
      utrerror.assert (
         v_dir IS NOT NULL,
         'Compile error: you must specify a directory with utConfig.setdir!'
      );
      fid :=
         UTL_FILE.fopen (
            v_dir,
            file_in,
            'R' &start_ge_8_1 
               ,
            max_linesize=> 32767 &end_ge_8_1
         );

      LOOP
         BEGIN
            UTL_FILE.get_line (
               fid,
               lines (  NVL (lines.LAST, 0)
                      + 1)
            );
            -- 2.0.7: helps with compiling in Linux. 
            lines (lines.LAST) :=
               RTRIM (
                  lines (lines.LAST),
                     ' '
                  || CHR (13)
               );
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
            lines.DELETE (lines.LAST);
         ELSE
            EXIT;
         END IF;
      END LOOP;

      UTL_FILE.fclose (fid);
	  
	  if tracing then 
	  utreport.pl ('Compiling ' || lines (lines.first));
	  end if;
	  
      DBMS_SQL.parse (
         cur,
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
      package_in            IN   VARCHAR2,
      samepackage_in        IN   BOOLEAN := FALSE,
      prefix_in             IN   VARCHAR2 := NULL,
      owner_in              IN   VARCHAR2 := NULL,
      subprogram_in         IN   VARCHAR2 := '%',
      override_package_in   IN   VARCHAR2
            := NULL -- 2.0.9.2
   )
   IS
      v_pkg   VARCHAR2 (1000);
   BEGIN
       --testpkg.pkg := package_in;
      -- 2.0.9.2
      testpkg.pkg :=
            NVL (override_package_in, package_in);
      testpkg.owner := owner_in; -- 2.0.9.1 remote schema
      testpkg.ispkg :=
                 ispackage (package_in, owner_in);

      -- 2.0.9.2 If there is an override package, treat like samepackage
      --         No addition of prefix, essentially

      IF override_package_in IS NOT NULL
      THEN
         testpkg.samepkg := TRUE;
      ELSE
         testpkg.samepkg := samepackage_in;
      END IF;

      testpkg.prefix :=
         NVL (
            prefix_in,
            utconfig.prefix (owner_in)
         );
      v_pkg := pkgname (
                  testpkg.pkg,
                  testpkg.samepkg,
                  testpkg.prefix,
                  testpkg.owner
               );

      -- 2.1.1 Initialize a ut_utp row/id
        DECLARE
           rec   ut_utp%ROWTYPE;
        BEGIN
           IF ututp.EXISTS (testpkg.owner, testpkg.pkg)
           THEN
              rec := ututp.onerow (testpkg.owner, testpkg.pkg);
           ELSE
              ututp.ADD (testpkg.pkg, testpkg.owner, id_out => rec.ID);
           END IF;
        
           utplsql2.set_current_utp (rec.ID);
           utrutp.initiate(utplsql2.runnum,rec.id);
        END;

   
     IF tracing
      THEN
         utreport.pl (   'Setpkg to '
             || testpkg.pkg);
         utreport.pl (
               '   Package and program = '
            || v_pkg
         );
         utreport.pl (
               '   Same package? '
            || bool2vc (testpkg.samepkg)
         );
         utreport.pl (
               '   Is package? '
            || bool2vc (testpkg.ispkg)
         );
         utreport.pl (   '   Prefix = '
             || testpkg.prefix);
      END IF;
   END;

   -- 2.0.8.2 Separate out population of test array
   PROCEDURE populate_test_array (
      testpkg_in       IN   test_rt,
      package_in       IN   VARCHAR2,
      samepackage_in   IN   BOOLEAN := FALSE,
      prefix_in        IN   VARCHAR2 := NULL,
      owner_in         IN   VARCHAR2 := NULL,
      subprogram_in    IN   VARCHAR2 := '%'
   )
   IS
      v_pkg   VARCHAR2 (1000)
   := -- 2.0.9.1 No owner prefix.
      pkgname (
         testpkg_in.pkg,
         testpkg_in.samepkg,
         testpkg_in.prefix
      );
   BEGIN
      -- 1.3.5
      IF NOT utconfig.registeringtest (
                NVL (UPPER (owner_in), USER)
             )
      THEN
         -- Populate test information from ALL_ARGUMENTS
         FOR rec IN
             &start_lt_9
             (SELECT DISTINCT object_name procedure_name
                         FROM all_arguments
                        WHERE owner =
                                 NVL (
                                    UPPER (
                                       owner_in
                                    ),
                                    USER
                                 )
                          AND package_name =
                                    UPPER (v_pkg)
                          AND object_name LIKE
                                    UPPER (
                                       prefix_in
                                    )
                                 || '%'
                          AND object_name LIKE
                                 UPPER (
                                       prefix_in
                                    || subprogram_in
                                 )
                          AND object_name NOT IN
                                 (UPPER (
                                        prefix_in
                                     || c_setup
                                  ),
                                  UPPER (
                                        prefix_in
                                     || c_teardown
                                  )
                                 ) ORDER BY procedure_name)
             &end_lt_9
             &start_ge_9
             (SELECT procedure_name
                FROM all_procedures
               WHERE owner = NVL (UPPER (owner_in), USER)
                 AND object_name = UPPER (v_pkg)
                 AND procedure_name LIKE    UPPER (prefix_in)
                                    || '%'
                 AND procedure_name LIKE
                                UPPER (   prefix_in
                                       || subprogram_in)
                 AND procedure_name NOT IN (UPPER (
                                                  prefix_in
                                               || c_setup
                                            ),
                                            UPPER (
                                                  prefix_in
                                               || c_teardown
                                            )
                                 ) ORDER BY procedure_name)
             &end_ge_9
         LOOP
            addtest (
               testpkg_in.pkg,
               rec.procedure_name,
               prefix_in,
               iterations_in=> 1,
               override_in=> TRUE
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
      package_in      IN   VARCHAR2,
      name_in         IN   VARCHAR2,
      prefix_in       IN   VARCHAR2,
      iterations_in   IN   PLS_INTEGER,
      override_in     IN   BOOLEAN
   )
   IS
      indx   PLS_INTEGER
                      :=   NVL (tests.LAST, 0)
                         + 1;
   BEGIN
      -- 1.3.5 Disable calls to addtest from setup.
      IF    utconfig.registeringtest
         OR (    NOT utconfig.registeringtest
             AND override_in
            )
      THEN
         IF tracing
         THEN
            utreport.pl ('Addtest');
            utreport.pl (
                  '   Package and program = '
               || package_in
               || '.'
               || name_in
            );
            utreport.pl (
                  '   Same package? '
               || bool2vc (testpkg.samepkg)
            );
            utreport.pl (
                  '   Override? '
               || bool2vc (override_in)
            );
            utreport.pl (   '   Prefix = '
                || prefix_in);
         END IF;

         -- 1.5.3: program name always already has prefix!
         tests (indx).pkg := package_in;
         tests (indx).prefix := prefix_in;
         tests (indx).NAME := name_in;
         tests (indx).iterations := iterations_in;
      END IF;
   END;

   PROCEDURE addtest (
      name_in         IN   VARCHAR2,
      prefix_in       IN   VARCHAR2 := NULL,
      iterations_in   IN   PLS_INTEGER := 1,
      override_in     IN   BOOLEAN := FALSE
   )
   IS
      indx   PLS_INTEGER
                      :=   NVL (tests.LAST, 0)
                         + 1;
   BEGIN
      addtest (
         testpkg.pkg,
         name_in,
         prefix_in,
         iterations_in,
         override_in
      );
   END;

   /* Test engine */

   /* 1.5.3. autocompiling used instead
   FUNCTION do_recompile (recomp IN BOOLEAN)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (    recomp
              AND (NVL (g_config.autocompile, c_yes) != c_no));
   END;
   */

   PROCEDURE test (
      package_in            IN   VARCHAR2,
      samepackage_in        IN   BOOLEAN := FALSE,
      prefix_in             IN   VARCHAR2 := NULL,
      recompile_in          IN   BOOLEAN := TRUE,
      dir_in                IN   VARCHAR2 := NULL,
      suite_in              IN   VARCHAR2 := NULL,
      owner_in              IN   VARCHAR2 := NULL,
      reset_results_in      IN   BOOLEAN := TRUE,
      from_suite_in         IN   BOOLEAN := FALSE,
      subprogram_in         IN   VARCHAR2 := '%',
      per_method_setup_in   IN   BOOLEAN := FALSE, -- 2.0.8
      override_package_in   IN   VARCHAR2
            := NULL -- 2.0.9.2
   )
   IS
      indx                 PLS_INTEGER;
      v_pkg                VARCHAR2 (100);
     -- 2.0.10.1: use dir in config
     v_dir maxvc2_t := NVL (dir_in, utconfig.dir);
      v_start              DATE              := SYSDATE;
      v_prefix             ut_config.prefix%TYPE
   := NVL (prefix_in, utconfig.prefix (owner_in));
      v_per_method_setup   BOOLEAN
              := NVL (per_method_setup_in, FALSE);

      PROCEDURE cleanup (
         per_method_setup_in   IN   BOOLEAN
      )
      IS
      BEGIN
         utresult.show;

         IF NOT per_method_setup_in
         THEN
            runprog (
                  v_prefix
               || c_teardown,
               TRUE
            );
         END IF;

         utpackage.upd (
            suite_in,
            package_in,
            v_start,
            SYSDATE,
            utresult.success,
            owner_in
         );

         -- 2.1.1 add recording of test in tables.
         utrutp.terminate(utplsql2.runnum, utplsql2.current_utp);
         
         IF reset_results_in
         THEN
            init_tests;
         END IF;
         
         IF suite_in IS NULL THEN
            utreport.close;
         END IF;
         		 
      END;
   BEGIN
      init (v_prefix, v_dir, from_suite_in);

      IF NOT progexists (package_in, owner_in)
      THEN
         utreport.pl (
               'Program named "'
            || package_in
            || '" does not exist.'
         );
      ELSE
         setpkg (
            package_in,
            samepackage_in,
            v_prefix,
            owner_in,
            subprogram_in,
            override_package_in
         );
         --v_pkg := pkgname (package_in, samepackage_in, v_prefix, owner_in);
         -- 2.0.9.2 Make sure record is used.
         v_pkg := pkgname (
                     testpkg.pkg,
                     testpkg.samepkg,
                     testpkg.prefix,
                     testpkg.owner
                  );

         IF      recompile_in
             AND utconfig.autocompiling (
                    owner_in
                 )
         THEN
            IF tracing
            THEN
               utreport.pl (
                     'Recompiling '
                  || v_pkg
                  || ' in '
                  || v_dir
               );
            END IF;

            utreceq.COMPILE (package_in);
         
            COMPILE (
                  -- 2.0.9.1 Package name without OWNER
                  -- 2.0.9.2 Switch to use of record based info.
                  --pkgname (package_in, samepackage_in, v_prefix)
                     --      || '.pks', dir_in);
                  pkgname (
                     testpkg.pkg,
                     testpkg.samepkg,
                     testpkg.prefix
                  )
               || '.pks',
               v_dir
            );
            COMPILE (
                  -- 2.0.9.1 Package name without OWNER
                  -- 2.0.9.2 Switch to use of record based info.
                  --pkgname (package_in, samepackage_in, v_prefix)
                     --      || '.pks', dir_in);
                  pkgname (
                     testpkg.pkg,
                     testpkg.samepkg,
                     testpkg.prefix
                  )
               || '.pkb',
               v_dir
            );
         END IF;

         IF NOT v_per_method_setup
         THEN
            runprog (
                  v_prefix
               || c_setup,
               TRUE
            );
         END IF;

         populate_test_array (
            testpkg,
            package_in,
            samepackage_in,
            v_prefix,
            owner_in,
            subprogram_in
         );
         indx := tests.FIRST;

         IF indx IS NULL
         THEN
            utreport.pl ('Warning!');
            utreport.pl (
               'Warning...no tests were identified for execution!'
            );
            utreport.pl ('Warning!');
         ELSE
            LOOP
               EXIT WHEN indx IS NULL;
               runit (
                  indx,
                  v_per_method_setup,
                  v_prefix
               );
               indx := tests.NEXT (indx);
            END LOOP;
         END IF;

         cleanup (v_per_method_setup);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         utassert.this (
               'utPLSQL.test failure: '
            || SQLERRM,
            FALSE
         );
         cleanup (FALSE);
   END;

   PROCEDURE testsuite (
      suite_in              IN   VARCHAR2,
      recompile_in          IN   BOOLEAN := TRUE,
      reset_results_in      IN   BOOLEAN := TRUE,
      per_method_setup_in   IN   BOOLEAN := FALSE, -- 2.0.8
      override_package_in   IN   BOOLEAN := FALSE
   )
   IS
      v_suite         ut_suite.id%TYPE
               := utsuite.id_from_name (suite_in);
      v_success       BOOLEAN            := TRUE;
      v_suite_start   DATE               := SYSDATE;
      v_pkg_start     DATE;
      v_override      VARCHAR2 (1000);
   BEGIN
      IF v_suite IS NULL
      THEN
         utassert.this (
               'Test suite with name "'
            || suite_in
            || '" does not exist.',
            FALSE
         );
         utresult.show;
      ELSE
         FOR rec IN  (SELECT   *
                          FROM ut_package
                         WHERE suite_id = v_suite
                      ORDER BY seq)
         LOOP
            v_pkg_start := SYSDATE;

            -- 2.0.9.2 Pass override request to individual test.
            IF override_package_in
            THEN
               v_override := rec.NAME;
            ELSE
               v_override := NULL;
            END IF;
-- 2.0.9.2 allow for continuation of tests if a single package fails
begin
            test (
               rec.NAME,
               vc2bool (rec.samepackage),
               rec.prefix,
               recompile_in,
               rec.dir,
               
--               v_suite,
               suite_in,
               rec.owner,
               reset_results_in=> FALSE,
               from_suite_in=> TRUE,
               per_method_setup_in=> per_method_setup_in,
               override_package_in=> v_override
            );
 -- 3/4/02 trap exceptions and continue with next package.
             EXCEPTION
                 WHEN OTHERS THEN
                   v_success := FALSE;
             END;
            IF utresult.failure
            THEN
               v_success := FALSE;
            END IF;
         END LOOP;

         utsuite.upd (
            v_suite,
            v_suite_start,
            SYSDATE,
            v_success
         );
      END IF;

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
      dir_in     IN   VARCHAR2,
      file_in    IN   VARCHAR2,
      delim_in   IN   VARCHAR2 := ','
   )
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE passdata (
      data_in    IN   VARCHAR2,
      delim_in   IN   VARCHAR2 := ','
   )
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
      sqlstr   VARCHAR2 (200)
   :=    'SELECT '
      || tab_in
      || '_seq.NEXTVAL FROM dual';
      fdbk     PLS_INTEGER;
      retval   PLS_INTEGER;
   BEGIN
      &start_ge_8_1
      EXECUTE IMMEDIATE sqlstr
         INTO retval;

      &start_ge_8_1
      &start_lt_8_1
      DECLARE
         fdbk   PLS_INTEGER;
         cur    PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      BEGIN
         DBMS_SQL.parse (
            cur,
            sqlstr,
            DBMS_SQL.native
         );
         DBMS_SQL.define_column (cur, 1, retval);
         fdbk := DBMS_SQL.execute_and_fetch (cur);
         DBMS_SQL.column_value (cur, 1, retval);
         DBMS_SQL.close_cursor (cur);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_SQL.close_cursor (cur);
            RAISE;
      END;

      &end_lt_8_1
      RETURN retval;
   END;

   FUNCTION ifelse (
      bool_in   IN   BOOLEAN,
      tval_in   IN   BOOLEAN,
      fval_in   IN   BOOLEAN
   )
      RETURN BOOLEAN
   IS
   BEGIN
      IF bool_in
      THEN
         RETURN tval_in;
      ELSE
         RETURN fval_in;
      END IF;
   END;

   FUNCTION ifelse (
      bool_in   IN   BOOLEAN,
      tval_in   IN   DATE,
      fval_in   IN   DATE
   )
      RETURN DATE
   IS
   BEGIN
      IF bool_in
      THEN
         RETURN tval_in;
      ELSE
         RETURN fval_in;
      END IF;
   END;

   FUNCTION ifelse (
      bool_in   IN   BOOLEAN,
      tval_in   IN   NUMBER,
      fval_in   IN   NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      IF bool_in
      THEN
         RETURN tval_in;
      ELSE
         RETURN fval_in;
      END IF;
   END;

   FUNCTION ifelse (
      bool_in   IN   BOOLEAN,
      tval_in   IN   VARCHAR2,
      fval_in   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF bool_in
      THEN
         RETURN tval_in;
      ELSE
         RETURN fval_in;
      END IF;
   END;

   -- 2.0.9.2: run a test package directly
   PROCEDURE run (
      testpackage_in        IN   VARCHAR2,
      prefix_in             IN   VARCHAR2 := NULL,
      suite_in              IN   VARCHAR2 := NULL,
      owner_in              IN   VARCHAR2 := NULL,
      reset_results_in      IN   BOOLEAN := TRUE,
      from_suite_in         IN   BOOLEAN := FALSE,
      subprogram_in         IN   VARCHAR2 := '%',
      per_method_setup_in   IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      test (
         package_in=> testpackage_in,
         samepackage_in=> FALSE,
         prefix_in=> prefix_in,
         recompile_in=> FALSE,
         dir_in=> NULL,
         suite_in=> suite_in,
         owner_in=> owner_in,
         reset_results_in=> reset_results_in,
         from_suite_in=> from_suite_in,
         subprogram_in=> subprogram_in,
         per_method_setup_in=> per_method_setup_in, -- 2.0.8
         override_package_in=> testpackage_in
      );
   END;

   PROCEDURE runsuite (
      suite_in              IN   VARCHAR2,
      reset_results_in      IN   BOOLEAN := TRUE,
      per_method_setup_in   IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      testsuite (
         suite_in=> suite_in,
         recompile_in=> FALSE,
         reset_results_in=> reset_results_in,
         per_method_setup_in=> per_method_setup_in, -- 2.0.8
         override_package_in=> TRUE
      );
   END;
END;
/
