CREATE OR REPLACE PACKAGE BODY utgen
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
Revision 1.3  2004/05/11 15:33:56  chrisrimmer
Added 9.2 specific code from Mark Vilrokx

Revision 1.2  2003/07/01 19:36:46  chrisrimmer
Added Standard Headers

************************************************************************/

   g_pkgstring      VARCHAR2 (32767);
   g_currrow        PLS_INTEGER      := NULL;
   g_firstbodyrow   PLS_INTEGER      := NULL;

   TYPE code_tt IS TABLE OF codeline_t
      INDEX BY BINARY_INTEGER;

   pkgarray         code_tt;

   -- 1.5.6 Generic string parser

   TYPE item_tt IS TABLE OF VARCHAR2 (2000)
      INDEX BY BINARY_INTEGER;

   PROCEDURE parse_string (
      string_in   IN       VARCHAR2,
      items_out   IN OUT   item_tt,
      delim_in    IN       VARCHAR2 := ','
   )
   IS 
      v_item       VARCHAR2 (32767);
      v_loc        PLS_INTEGER;
      v_startloc   PLS_INTEGER      := 1;

      PROCEDURE add_item (item_in IN VARCHAR2)
      IS
      BEGIN
         IF (item_in != delim_in OR item_in IS NULL)
         THEN
            items_out (NVL (items_out.LAST, 0) + 1) := item_in;
         END IF;
      END;
   BEGIN
      items_out.DELETE;

      LOOP
         -- Find next delimiter
         v_loc := INSTR (string_in, delim_in, v_startloc);

         IF v_loc = v_startloc -- Previous item is NULL
         THEN
            v_item := NULL;
         ELSIF v_loc = 0 -- Rest of string is last item
         THEN
            v_item := SUBSTR (string_in, v_startloc);
         ELSE
            v_item := SUBSTR (string_in, v_startloc, v_loc - v_startloc);
         END IF;

         add_item (v_item);

         IF v_loc = 0
         THEN
            EXIT;
         ELSE
            add_item (delim_in);
            v_startloc := v_loc + 1;
         END IF;
      END LOOP;
   END parse_string;

   PROCEDURE get_nextline (
      file_in    IN       UTL_FILE.file_type,
      line_out   OUT      VARCHAR2,
      eof_out    OUT      BOOLEAN
   )
   IS
   BEGIN
      UTL_FILE.get_line (file_in, line_out);
      eof_out := FALSE ;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         line_out := NULL;
         eof_out := TRUE ;
   END;

   -- 1.5.6: add this and rewrite isfunction

   FUNCTION return_type (
      schema_in     IN   VARCHAR2,
      package_in    IN   VARCHAR2,
      program_in    IN   VARCHAR2,
      overload_in   IN   PLS_INTEGER := NULL
   )
      RETURN VARCHAR2
   IS 
      retval   all_arguments.data_type%TYPE;
   BEGIN
      SELECT data_type
        INTO retval
        FROM all_arguments
       WHERE owner = NVL (UPPER (schema_in), USER)
         AND (   package_name = UPPER (package_in)
              OR (package_name IS NULL AND package_in IS NULL)
             )
         AND object_name = UPPER (program_in)
         AND (   overload = overload_in
              OR (overload IS NULL AND overload_in IS NULL)
             )
         AND argument_name IS NULL
         AND POSITION = 0;

      IF retval LIKE 'PL/SQL%'
      THEN
         -- Change "PL/SQL BOOLEAN" to "BOOLEAN" and so on...
         retval := SUBSTR (retval, 8);
      ELSIF retval IN ('VARCHAR2', 'VARCHAR', 'CHAR')
      THEN
         -- Make it a legal string declaration.
         retval := retval || '(2000)';
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION isfunction (
      schema_in     IN   VARCHAR2,
      package_in    IN   VARCHAR2,
      program_in    IN   VARCHAR2,
      overload_in   IN   PLS_INTEGER := NULL
   )
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (return_type (schema_in, package_in, program_in, overload_in) IS NOT NULL);
   END;

   PROCEDURE testpkg (
      package_in           IN   VARCHAR2,
      grid_in              IN   grid_tt,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      delim_in             IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS 
      fid            UTL_FILE.file_type;
      v_ispkg        BOOLEAN     := utplsql.ispackage (package_in, schema_in);
      v_dir          VARCHAR2 (2000)    := NVL (dir_in, utconfig.dir);
      v_pkg          VARCHAR2 (100);
      v_progprefix   VARCHAR2 (100);
      -- Used in queries against ALL_ARGUMENTS
      v_objpackage   VARCHAR2 (100);
      v_objprogram   VARCHAR2 (100);
      l_grid         grid_tt;

      CURSOR prog_cur (package_in IN VARCHAR2, program_in IN VARCHAR2)
      IS &startnot92
         SELECT DISTINCT owner, package_name, object_name, overload,
                         object_name || overload
                               full_name
                    FROM all_arguments
                   WHERE     owner = NVL (UPPER (schema_in), USER)
                         AND (    package_name = UPPER (package_in)
                              AND object_name LIKE
                                                 NVL (UPPER (program_in), '%')
                             )
                      OR (    (   package_name IS NULL
                               -- 2.0.9.1 9i changes way package_name is set.
                               OR package_name = UPPER (program_in)
                              )
                          AND package_in IS NULL
                          AND object_name = UPPER (program_in)
                         );
         &endnot92
         &start92
         SELECT owner, object_name package_name, procedure_name object_name,
                DECODE (
                   ROW_NUMBER () OVER (PARTITION BY procedure_name ORDER BY object_name),
                   1, NULL,
                   ROW_NUMBER () OVER (PARTITION BY procedure_name ORDER BY object_name)
                ) overload,
                   procedure_name
                || DECODE (
                      ROW_NUMBER () OVER (PARTITION BY procedure_name ORDER BY object_name),
                      1, NULL,
                      ROW_NUMBER () OVER (PARTITION BY procedure_name ORDER BY object_name)
                ) full_name
           FROM all_procedures
          WHERE     owner = NVL (UPPER (schema_in), USER)
                AND (    object_name = UPPER (package_in)
                     AND procedure_name LIKE
                                        NVL (UPPER (program_in), '%')
                    )
             OR (    (   object_name IS NULL
                      -- 2.0.9.1 9i changes way package_name is set.
                      OR object_name = UPPER (program_in)
                     )
                 AND package_in IS NULL
                 AND procedure_name = UPPER (program_in)
                );         
         &end92

      CURSOR arg_cur (
         schema_in     IN   VARCHAR2,
         package_in    IN   VARCHAR2,
         program_in    IN   VARCHAR2,
         overload_in   IN   PLS_INTEGER
      )
      IS
         SELECT   argument_name, data_type
             FROM all_arguments
            WHERE owner = schema_in
              AND (   package_name = package_in
                   OR (package_name IS NULL AND package_in IS NULL)
                  )
              AND object_name = program_in
              AND argument_name IS NOT NULL
              AND (   overload = overload_in
                   OR (overload IS NULL AND overload_in IS NULL)
                  )
         ORDER BY POSITION;

      arg            arg_cur%ROWTYPE;
      noargs         BOOLEAN;

      PROCEDURE setup (ext IN VARCHAR2 := NULL)
      IS
      BEGIN
         IF output_type_in = c_screen
         THEN
            NULL;
         ELSIF output_type_in = c_string
         THEN
            g_pkgstring := NULL;
         ELSIF output_type_in = c_array
         THEN
            pkgarray.DELETE;
            g_currrow := NULL;
            g_firstbodyrow := NULL;
         ELSIF output_type_in = c_file
         THEN
            utassert.this (
               'Compile error: you must specify a directory with utConfig.setdir!',
               v_dir IS NOT NULL,
               register_in      => FALSE
            );

            IF utplsql.tracing
            THEN
               utplsql.pl (v_dir || '-' || package_in || '.' || ext);
            END IF;

            fid := UTL_FILE.fopen (
                      v_dir,
		 		 		 		 		   NVL (override_file_in, 
                         NVL (prefix_in, utconfig.prefix (schema_in))
                      || package_in
                      || '.'
                      || ext),
                      'W'
                   &start81 , max_linesize => 32767 &end81
                   );
         END IF;
      END;

      PROCEDURE putline (str IN VARCHAR2)
      IS
      BEGIN
         IF output_type_in = c_screen
         THEN
            utplsql.pl (str);
         ELSIF output_type_in = c_string
         THEN
            g_pkgstring := g_pkgstring || '|' || str;
         ELSIF output_type_in = c_array
         THEN
            pkgarray (NVL (pkgarray.LAST, 0) + 1) := str;
         ELSIF output_type_in = c_file
         THEN
            UTL_FILE.put_line (fid, str);
         END IF;
      END;

      PROCEDURE cleanup
      IS
      BEGIN
         IF output_type_in = c_screen
         THEN
            NULL;
         ELSIF output_type_in = c_string
         THEN
            g_pkgstring := LTRIM (g_pkgstring, '|');
         ELSIF output_type_in = c_file
         THEN
            UTL_FILE.fclose (fid);
         END IF;
      END;

      FUNCTION program_call ( -- 2.0.9.1 switch to whole record
      rec             IN   prog_cur%ROWTYPE,
         is_package   IN   BOOLEAN               /*
                                                   package_in   IN   VARCHAR2,
                                                   program_in   IN   VARCHAR2 */
      )
         RETURN VARCHAR2
      IS
      BEGIN
         IF rec.package_name IS NOT NULL AND is_package
         THEN
            RETURN rec.package_name || '.' || rec.object_name;
         ELSE
            RETURN rec.object_name;
         END IF;
      END;

      PROCEDURE iputline (string_in IN VARCHAR2, indentby_in IN PLS_INTEGER
               := 3)
      IS
      BEGIN
         putline (LPAD (' ', indentby_in, ' ') || string_in);
      END;

      PROCEDURE i6putline (string_in IN VARCHAR2)
      IS
      BEGIN
         putline (LPAD (' ', 6, ' ') || string_in);
      END;

      FUNCTION include_program (
         NAME_IN            IN   VARCHAR2,
         overload_in        IN   PLS_INTEGER,
         curr_name_in       IN   VARCHAR2,
         curr_overload_in   IN   PLS_INTEGER
      )
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN (    UPPER (NAME_IN) = curr_name_in
                 AND (   overload_in = curr_overload_in
                      OR (overload_in = 1 AND curr_overload_in IS NULL)
                      OR (overload_in IS NULL AND curr_overload_in IS NULL)
                     )
                );
      -- OR v_objprogram = '%';
      END;

      FUNCTION include_program (rec IN prog_cur%ROWTYPE, grid_in IN grid_tt)
         RETURN BOOLEAN
      IS 
         retval       BOOLEAN     := NOT only_if_in_grid_in;
         grid_index   PLS_INTEGER := grid_in.FIRST;
      BEGIN
         -- Does the program in rec appear at all in grid_in?
         IF only_if_in_grid_in
         THEN
            LOOP
               EXIT WHEN grid_index IS NULL;

               IF include_program (
                     grid_in (grid_index).progname,
                     grid_in (grid_index).overload,
                     rec.object_name,
                     rec.overload
                  )
               THEN
                  retval := TRUE ;
                  EXIT;
               ELSE
                  grid_index := grid_in.NEXT (grid_index);
               END IF;
            END LOOP;
         END IF;

         RETURN retval;
      END;

      PROCEDURE generate_setup (
         prefix_in       IN   VARCHAR2,
         schema_in       IN   VARCHAR2,
         objpackage_in   IN   VARCHAR2,
         objprogram_in   IN   VARCHAR2
      )
      IS
      BEGIN
         iputline ('PROCEDURE ' || prefix_in || 'setup');
         iputline ('IS');
         iputline ('BEGIN');

         IF utconfig.registeringtest (schema_in)
         THEN
            iputline ('   -- For each program to test...');

            FOR rec IN prog_cur (objpackage_in, objprogram_in)
            LOOP
               IF include_program (rec, grid_in)
               THEN
                  iputline ('   utPLSQL.addtest (''' || rec.full_name || ''');');
               END IF;
            END LOOP;
         ELSE
            iputline ('   NULL;');
         END IF;

         iputline ('END;');
         iputline ('');
      END;

      PROCEDURE generate_teardown (prefix_in IN VARCHAR2)
      IS
      BEGIN
         iputline ('PROCEDURE ' || prefix_in || 'teardown');
         iputline ('IS');
         iputline ('BEGIN');
         iputline ('   NULL;');
         iputline ('END;');
      END;

      FUNCTION is_expression (string_in IN VARCHAR2)
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN SUBSTR (string_in, 1, 1) = c_asis;
      END;

      PROCEDURE generate_ut_procedure (
         prefix_in   IN   VARCHAR2,
         rec         IN   prog_cur%ROWTYPE,
         /*schema_in       IN   VARCHAR2,
         objpackage_in   IN   VARCHAR2,
         objprogram_in   IN   VARCHAR2,*/
         grid_in     IN   grid_tt
      )
      IS 
         v_isfunction   BOOLEAN;
         v_datatype     VARCHAR2 (100);

         FUNCTION data_value (value_in IN VARCHAR2, type_in IN VARCHAR2)
            RETURN VARCHAR2
         IS 
            retval   VARCHAR2 (2000) := value_in;
         BEGIN
            IF is_expression (value_in)
            THEN
               retval := SUBSTR (value_in, 2);
            ELSIF value_in IS NULL OR UPPER (value_in) = 'NULL'
            THEN
               retval := 'NULL';
            ELSIF type_in LIKE '%CHAR%'
            THEN
               retval := '''' || value_in || '''';
            ELSIF type_in IN ('NUMBER', 'FLOAT') OR type_in LIKE '%INT%'
            THEN
               retval := value_in;
            ELSIF type_in IN ('BOOLEAN', 'PL/SQL BOOLEAN')
            THEN
               retval := value_in;
            ELSIF type_in LIKE '%DATE%'
            THEN
               retval :=    'TO_DATE ('''
                         || value_in
                         || ''', '''
                         || date_format_in
                         || ''')';
            END IF;

            RETURN retval;
         END;

         PROCEDURE generate_testcase (
            rec             IN   prog_cur%ROWTYPE,
            isfunction_in   IN   BOOLEAN,
            datatype_in     IN   VARCHAR2,
            grid_in         IN   grid_rt
         )
         IS 
            l_entries   item_tt;

            PROCEDURE putarg (
               arg_in      IN   arg_cur%ROWTYPE,
               ntharg_in   IN   PLS_INTEGER
            )
            IS
            BEGIN
               IF l_entries.COUNT > 0
               THEN
                  i6putline (
                        '   '
                     || arg_in.argument_name
                     || ' => '
                     || data_value (l_entries (ntharg_in), arg_in.data_type)
                  );
               ELSE
                  i6putline ('   ' || arg_in.argument_name || ' => ''''');
               END IF;
            END;

            FUNCTION testname
               RETURN VARCHAR2
            IS
            BEGIN
               IF grid_in.progname IS NOT NULL
               THEN
                  RETURN ' for "' || grid_in.tcname || '"';
               ELSE
                  RETURN NULL;
               END IF;
            END;
         BEGIN
            i6putline ('');
            i6putline ('-- Define "control" operation' || testname);
            i6putline (' ');

            IF isfunction_in
            THEN
               i6putline (
                     'against_this := '
                  || data_value (grid_in.return_value, datatype_in)
                  || ';'
               );
            END IF;

            i6putline (' ');
            i6putline ('-- Execute test code' || testname);
            i6putline (' ');
            OPEN arg_cur (
               rec.owner,
               rec.package_name,
               rec.object_name,
               rec.overload
            );
            FETCH arg_cur INTO arg;
            noargs := arg_cur%NOTFOUND;

            IF isfunction_in
            THEN
               i6putline ('check_this := ');
            END IF;

            IF noargs
            THEN
               i6putline ( -- 2.0.9.1: use procedure, not explicit concat.
               program_call (rec, v_ispkg) || ';'
               );
            ELSE
               i6putline (program_call (rec, v_ispkg) || ' (');

               IF grid_in.arglist IS NOT NULL
               THEN
                  parse_string (grid_in.arglist, l_entries, delim_in);
               END IF;

               WHILE arg_cur%FOUND
               LOOP
                  putarg (arg, arg_cur%ROWCOUNT);
                  FETCH arg_cur INTO arg;

                  IF arg_cur%FOUND
                  THEN
                     i6putline ('   ,');
                  END IF;
               END LOOP;

               iputline ('    );');
            END IF;

            CLOSE arg_cur;
            i6putline (' ');
            i6putline ('-- Assert success' || testname);
            i6putline (' ');

            
-- Here I should access information in ut_assertion table to dynamically
            -- build the call to the utAssert procedure. For now, I will hard code
            -- for EQ and ISNULL to demonstrate the possibilities.

            IF v_isfunction
            THEN
               IF    grid_in.assertion_type = 'EQ'
                  OR grid_in.assertion_type IS NULL
               THEN
                  i6putline ('-- Compare the two values.');
                  i6putline ('utAssert.eq (');
                  i6putline (
                        '   '''
                     || NVL (grid_in.MESSAGE, 'Test of ' || rec.object_name)
                     || ''','
                  );
                  i6putline ('   check_this,');
                  i6putline ('   against_this');
                  i6putline ('   );');
               ELSIF grid_in.assertion_type = 'ISNULL'
               THEN
                  i6putline ('-- Check for NULL return value.');
                  i6putline ('utAssert.isNULL (');
                  i6putline (
                        '   '''
                     || NVL (
                           grid_in.MESSAGE,
                           'NULL Test for ' || rec.object_name
                        )
                     || ''','
                  );
                  i6putline ('   check_this');
                  i6putline ('   );');
               END IF;
            ELSE
               i6putline ('utAssert.this (');
               i6putline (
                     '   '''
                  || NVL (grid_in.MESSAGE, 'Test of ' || rec.object_name)
                  || ''','
               );
               i6putline ('   ''<boolean expression>''');
               i6putline ('   );');
            END IF;

            i6putline ('');
            i6putline ('-- End of test' || testname);
         END;

         PROCEDURE generate_testcase (
            rec             IN   prog_cur%ROWTYPE,
            isfunction_in   IN   BOOLEAN,
            datatype_in     IN   VARCHAR2
         )
         IS 
            l_empty   grid_rt;
         BEGIN
            generate_testcase (rec, isfunction_in, datatype_in, l_empty);
         END;
      BEGIN
         v_isfunction := isfunction (
                            rec.owner,
                            rec.package_name,
                            rec.object_name,
                            rec.overload
                         );

         IF v_isfunction
         THEN
            v_datatype := return_type (
                             rec.owner,
                             rec.package_name,
                             rec.object_name,
                             rec.overload
                          );
         END IF;

         iputline ('PROCEDURE ' || prefix_in || rec.full_name);
         iputline ('IS');

         IF v_isfunction
         THEN
            i6putline ('-- Verify and complete data types.');
            i6putline ('against_this ' || v_datatype || ';');
            i6putline ('check_this ' || v_datatype || ';');
         END IF;

         iputline ('BEGIN');

         IF grid_in.COUNT = 0
         THEN
            generate_testcase (rec, v_isfunction, v_datatype);
         ELSE
            FOR indx IN grid_in.FIRST .. grid_in.LAST
            LOOP
               generate_testcase (
                  rec,
                  v_isfunction,
                  v_datatype,
                  grid_in (indx)
               );
            END LOOP;
         END IF;

         iputline ('END ' || v_progprefix || rec.full_name || ';');
         putline ('');
      END;
   BEGIN                                                      /* MAIN TESTPKG */
      utassert.this (
         'Invalid target to generate a package: ' || output_type_in,
         output_type_in IN (c_string, c_screen, c_file, c_array),
         register_in      => FALSE
      );
      v_pkg := utplsql.pkgname (
                  package_in,
                  samepackage_in,
                  NVL (prefix_in, utconfig.prefix (schema_in)),
                  v_ispkg
               );
      v_progprefix := utplsql.progname (
                         NULL,
                         samepackage_in,
                         NVL (prefix_in, utconfig.prefix (schema_in)),
                         v_ispkg
                      );

      IF v_ispkg
      THEN
         v_objpackage := UPPER (package_in);
         v_objprogram := UPPER (program_in);
      ELSE
         v_objpackage := NULL;
         v_objprogram := UPPER (package_in);
      END IF;

      setup ('pks');

      -- Spit out the package spec

      IF samepackage_in
      THEN
         putline ('-- START: place in specification of source package');
      ELSE
         putline ('CREATE OR REPLACE PACKAGE ' || v_pkg);
         putline ('IS');
      END IF;

      putline ('   PROCEDURE ' || v_progprefix || 'setup;');
      putline ('   PROCEDURE ' || v_progprefix || 'teardown;');
      putline (' ');
      putline ('   -- For each program to test...');

      FOR rec IN prog_cur (v_objpackage, v_objprogram)
      LOOP
         IF include_program (rec, grid_in)
         THEN
            putline ('   PROCEDURE ' || v_progprefix || rec.full_name || ';');
         END IF;
      END LOOP;

      IF samepackage_in
      THEN
         putline ('-- END: place in specification of source package');
      ELSE
         putline ('END ' || v_pkg || ';');
         putline ('/');
      END IF;

      -- Spit out the package body into a separate file

      IF output_type_in = c_file
      THEN
         cleanup;
         setup ('pkb');
      ELSIF output_type_in = c_array
      THEN
         g_firstbodyrow := pkgarray.LAST + 1;
      END IF;

      IF samepackage_in
      THEN
         putline ('-- START: place in body of source package');
      ELSE
         putline ('CREATE OR REPLACE PACKAGE BODY ' || v_pkg);
         putline ('IS');
      END IF;

      generate_setup (v_progprefix, schema_in, v_objpackage, v_objprogram);
      generate_teardown (v_progprefix);
      putline ('   -- For each program to test...');

      FOR rec IN prog_cur (v_objpackage, v_objprogram)
      LOOP
         l_grid.DELETE;

         IF grid_in.COUNT > 0
         THEN
            /*
            Go through the grid, pulling out only those test case rows
            for the current program and then populate the test case procedure
            accordingly.
            */
            FOR indx IN grid_in.FIRST .. grid_in.LAST
            LOOP
               -- should switch to passing in records.
               IF include_program (
                     grid_in (indx).progname,
                     grid_in (indx).overload,
                     rec.object_name,
                     rec.overload
                  )
               THEN
                  l_grid (indx) := grid_in (indx);
               END IF;
            END LOOP;
         END IF;

         IF l_grid.COUNT > 0 OR NOT NVL (only_if_in_grid_in, FALSE )
--         IF      l_grid.COUNT > 0
         THEN
            generate_ut_procedure (
               v_progprefix,
               rec,                                          /*schema_in,
                                                             rec.package_name,
                                                             rec.object_name,*/
               l_grid
            );
         END IF;
      END LOOP;

      IF samepackage_in
      THEN
         putline ('-- END: place in body of source package');
      ELSE
         putline ('END ' || v_pkg || ';');
         putline ('/');
      END IF;

      cleanup;
   END testpkg;

   PROCEDURE clean_up_file_io (
      prog_in   IN       VARCHAR2,
      file_in   IN OUT   UTL_FILE.file_type,
      err_in    IN       VARCHAR2 := NULL
   )
   IS
   BEGIN
      UTL_FILE.fclose (file_in);

      IF err_in IS NOT NULL
      THEN
         utplsql.pl (prog_in || ' File IO failure: ' || err_in);
      END IF;
   END;

   PROCEDURE testpkg (
      package_in       IN   VARCHAR2,
      program_in       IN   VARCHAR2 := '%',
      samepackage_in   IN   BOOLEAN := FALSE ,
      prefix_in        IN   VARCHAR2 := NULL,
      schema_in        IN   VARCHAR2 := NULL,
      output_type_in   IN   PLS_INTEGER := c_screen,
      dir_in           IN   VARCHAR2 := NULL,
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS 
      l_grid   grid_tt;
   BEGIN
      -- pass an empty grid to the engine.
      testpkg (
         package_in,
         l_grid,
         program_in,
         samepackage_in,
         prefix_in,
         schema_in,
         output_type_in,
         dir_in,
         only_if_in_grid_in      => FALSE,
		 		  override_file_in => override_file_in
      );
   END;

   FUNCTION valid_entry (string_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN string_in IS NOT NULL AND string_in NOT LIKE '#%';
   END;

   PROCEDURE testpkg_from_file (
      package_in           IN   VARCHAR2,
      gridfile_loc_in      IN   VARCHAR2,
      gridfile_in          IN   VARCHAR2,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      field_delim_in       IN   VARCHAR2 := '|',
      arg_delim_in         IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS 
      c_progname   VARCHAR2 (30)      := 'testpkg_from_file';
      fid          UTL_FILE.file_type;
      l_line       VARCHAR2 (1000);
      l_eof        BOOLEAN;
      l_entries    item_tt;
      l_grid       grid_tt;
      l_indx       PLS_INTEGER;
   BEGIN
      fid := UTL_FILE.fopen (gridfile_loc_in, gridfile_in, 'R');

      LOOP
         get_nextline (fid, l_line, l_eof);
         l_line := LTRIM (l_line);
         EXIT WHEN l_eof;

         IF valid_entry (l_line)
         THEN
            parse_string (l_line, l_entries, field_delim_in);
            l_indx := NVL (l_grid.LAST, 0) + 1;
            l_grid (l_indx).progname := UPPER (l_entries (1));
            l_grid (l_indx).overload := l_entries (2);
            l_grid (l_indx).tcname := l_entries (3);
            l_grid (l_indx).MESSAGE := l_entries (4);
            l_grid (l_indx).arglist := l_entries (5);
            l_grid (l_indx).return_value := l_entries (6);
            l_grid (l_indx).assertion_type := UPPER (l_entries (7));
         END IF;
      END LOOP;

      clean_up_file_io (c_progname, fid);
      testpkg (
         package_in,
         l_grid,
         program_in,
         samepackage_in,
         prefix_in,
         schema_in,
         output_type_in,
         dir_in,
         arg_delim_in,
         date_format_in,
         only_if_in_grid_in,
		 		  override_file_in => override_file_in
      );
   EXCEPTION
      WHEN UTL_FILE.invalid_path
      THEN
         clean_up_file_io (c_progname, fid, 'invalid_path');
      WHEN UTL_FILE.invalid_mode
      THEN
         clean_up_file_io (c_progname, fid, 'invalid_mode');
      WHEN UTL_FILE.invalid_filehandle
      THEN
         clean_up_file_io (c_progname, fid, 'invalid_filehandle');
      WHEN UTL_FILE.invalid_operation
      THEN
         clean_up_file_io (c_progname, fid, 'invalid_operation');
      WHEN UTL_FILE.read_error
      THEN
         clean_up_file_io (c_progname, fid, 'read_error');
      WHEN UTL_FILE.write_error
      THEN
         clean_up_file_io (c_progname, fid, 'write_error');
      WHEN UTL_FILE.internal_error
      THEN
         clean_up_file_io (c_progname, fid, 'internal_error');
      WHEN OTHERS
      THEN
         clean_up_file_io (c_progname, fid, SQLERRM);
   END testpkg_from_file;

   PROCEDURE testpkg_from_string (
      package_in           IN   VARCHAR2,
      grid_in              IN   VARCHAR2,
      program_in           IN   VARCHAR2 := '%',
      samepackage_in       IN   BOOLEAN := FALSE ,
      prefix_in            IN   VARCHAR2 := NULL,
      schema_in            IN   VARCHAR2 := NULL,
      output_type_in       IN   PLS_INTEGER := c_screen,
      dir_in               IN   VARCHAR2 := NULL,
      line_delim_in        IN   VARCHAR := CHR (10),
      field_delim_in       IN   VARCHAR2 := '|',
      arg_delim_in         IN   VARCHAR2 := c_delim,
      date_format_in       IN   VARCHAR2 := 'MM/DD/YYYY',
      only_if_in_grid_in   IN   BOOLEAN := FALSE,
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS 
      c_progname   VARCHAR2 (30)   := 'testpkg_from_string';
      l_line       VARCHAR2 (1000);
      l_lines      item_tt;
      l_entries    item_tt;
      l_grid       grid_tt;
      l_indx       PLS_INTEGER;
   BEGIN
      IF grid_in IS NOT NULL
      THEN
         parse_string (grid_in, l_lines, line_delim_in);

         FOR l_linenum IN l_lines.FIRST .. l_lines.LAST
         LOOP
            IF valid_entry (l_lines (l_linenum))
            THEN
               parse_string (l_lines (l_linenum), l_entries, field_delim_in);
               l_indx := NVL (l_grid.LAST, 0) + 1;
               l_grid (l_indx).progname := UPPER (l_entries (1));
               l_grid (l_indx).overload := l_entries (2);
               l_grid (l_indx).tcname := l_entries (3);
               l_grid (l_indx).MESSAGE := l_entries (4);
               l_grid (l_indx).arglist := l_entries (5);
               l_grid (l_indx).return_value := l_entries (6);
               l_grid (l_indx).assertion_type := UPPER (l_entries (7));
            END IF;
         END LOOP;

         testpkg (
            package_in,
            l_grid,
            program_in,
            samepackage_in,
            prefix_in,
            schema_in,
            output_type_in,
            dir_in,
            arg_delim_in,
            date_format_in,
            only_if_in_grid_in,
		 		     override_file_in => override_file_in
         );
      END IF;
   END;

   PROCEDURE testpkg_from_string_od (
      package_in   IN   VARCHAR2,
      grid_in      IN   VARCHAR2,
      dir_in       IN   VARCHAR2 := NULL,
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS
   BEGIN
      testpkg_from_string (
         package_in,
         grid_in,
         output_type_in          => c_file,
         dir_in                  => dir_in,
         only_if_in_grid_in      => TRUE,
		 		  override_file_in => override_file_in
      );
   END;

   PROCEDURE clear_grid (
      owner_in            IN   ut_grid.owner%TYPE
		  ,package_in          IN   ut_grid.PACKAGE%TYPE)
   IS
   BEGIN
   delete from ut_grid  WHERE ut_grid.owner = UPPER (owner_in)
		 		 		   AND ut_grid.PACKAGE = UPPER (package_in);
		 		 		   
   END;
   
   PROCEDURE add_to_grid (
      owner_in            IN   ut_grid.owner%TYPE
		  ,package_in          IN   ut_grid.PACKAGE%TYPE
     ,progname_in         IN   ut_grid.progname%TYPE
     ,overload_in         IN   ut_grid.overload%TYPE
     ,tcname_in           IN   ut_grid.tcname%TYPE
     ,message_in          IN   ut_grid.MESSAGE%TYPE
     ,arglist_in          IN   ut_grid.arglist%TYPE
     ,return_value_in     IN   ut_grid.return_value%TYPE
     ,assertion_type_in   IN   ut_grid.assertion_type%TYPE
   )
   IS
   BEGIN
      INSERT INTO ut_grid
                  (owner, PACKAGE, progname, overload, tcname, MESSAGE
                  ,arglist, return_value, assertion_type
                  )
           VALUES (owner_in, package_in, progname_in, overload_in, tcname_in, message_in
                  ,arglist_in, return_value_in, assertion_type_in
                  );
   END add_to_grid;
   
   -- 2.0.10.1  From Patrick Barel
/* START Patch72 607131 */
   PROCEDURE testpkg_from_table (
      package_in       IN   VARCHAR2,
      program_in       IN   VARCHAR2 := '%',
      samepackage_in   IN   BOOLEAN := FALSE ,
      prefix_in        IN   VARCHAR2 := NULL,
      schema_in        IN   VARCHAR2 := NULL,
      output_type_in   IN   PLS_INTEGER := c_screen,
      dir_in           IN   VARCHAR2 := NULL,
      date_format_in   IN   VARCHAR2 := 'MM/DD/YYYY',
		   override_file_in IN   VARCHAR2 := NULL
   )
   IS 
      CURSOR c_ut_grid (p_package VARCHAR2, p_owner VARCHAR2)
      IS
         SELECT   ut_grid.owner,
		 		           ut_grid.progname, ut_grid.overload, ut_grid.tcname,
                  ut_grid.MESSAGE, ut_grid.arglist, ut_grid.return_value,
                  ut_grid.assertion_type
             FROM ut_grid
            WHERE NVL(ut_grid.owner, USER) = UPPER (p_owner)
		 		 		   AND ut_grid.PACKAGE = UPPER (p_package)
         ORDER BY ut_grid.progname;

      lv_grid      utgen.grid_tt;
      rc_ut_grid   c_ut_grid%ROWTYPE;
      lv_index     NUMBER              := -1;
   BEGIN
      IF c_ut_grid%ISOPEN
      THEN
         CLOSE c_ut_grid;
      END IF; -- c_ut_grid%IsOpen

      OPEN c_ut_grid (p_package => package_in, p_owner => NVL (schema_in, USER));
      FETCH c_ut_grid INTO rc_ut_grid;

      WHILE c_ut_grid%FOUND
      LOOP
         lv_index := lv_index + 1;
         lv_grid (lv_index).progname := rc_ut_grid.progname;
         lv_grid (lv_index).overload := rc_ut_grid.overload;
         lv_grid (lv_index).tcname := rc_ut_grid.tcname;
         lv_grid (lv_index).MESSAGE := rc_ut_grid.MESSAGE;
         lv_grid (lv_index).arglist := rc_ut_grid.arglist;
         lv_grid (lv_index).return_value := rc_ut_grid.return_value;
         lv_grid (lv_index).assertion_type := rc_ut_grid.assertion_type;
         FETCH c_ut_grid INTO rc_ut_grid;
      END LOOP;

      IF c_ut_grid%ISOPEN
      THEN
         CLOSE c_ut_grid;
      END IF; -- c_ut_grid%IsOpen

      IF lv_index > -1
      THEN
/*         utgen.testpkg (
            package_in          => package_in,
            grid_in             => lv_grid,
            date_format_in      => date_format_in
         );
*/
-- We have access to all parameters (either sent in or default). Why not use them?
         utgen.testpkg (
            package_in       => package_in /* SEF fix 10/9/2 lv_package*/
          , grid_in          => lv_grid
          , program_in       => program_in
          , samepackage_in   => samepackage_in
          , prefix_in        => prefix_in
          , schema_in        => schema_in
          , output_type_in   => output_type_in
          , dir_in           => dir_in
          , date_format_in   => date_format_in
		 		   , override_file_in => override_file_in
          );

      END IF; -- lv_index > -1
   END;
/* END Patch72 607131 */

   FUNCTION pkgstring
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_pkgstring;
   END;

   /* Returns data in order retrieved (ie, Nth row). */
   FUNCTION nthrow (nth IN PLS_INTEGER, direction IN SIGNTYPE := 1)
      RETURN codeline_t
   IS 
      v_nth    PLS_INTEGER := 1;
      v_row    PLS_INTEGER;
      retval   codeline_t;
   BEGIN
      IF direction = 1
      THEN
         v_row := pkgarray.FIRST;
      ELSE
         v_row := pkgarray.LAST;
      END IF;

      /* Since no prep work was done, do a scan through table. */
      LOOP
         EXIT WHEN v_row IS NULL;

         IF v_nth = nth
         THEN
            retval := pkgarray (v_row);
            EXIT;
         ELSE
            v_nth := v_nth + 1;

            IF direction = 1
            THEN
               v_row := pkgarray.NEXT (v_row);
            ELSE
               v_row := pkgarray.PRIOR (v_row);
            END IF;
         END IF;
      END LOOP;

      RETURN retval;
   END;

   FUNCTION firstrow
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN pkgarray.FIRST;
   END;

   FUNCTION lastrow
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN pkgarray.LAST;
   END;

   FUNCTION atfirstrow
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_currrow = pkgarray.FIRST;
   END;

   FUNCTION atlastrow
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_currrow = pkgarray.LAST;
   END;

   FUNCTION firstbodyrow
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_firstbodyrow;
   END;

   FUNCTION countrows
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN pkgarray.COUNT;
   END;

   PROCEDURE init_currrow
   IS
   BEGIN
      IF g_currrow IS NULL
      THEN
         g_currrow := pkgarray.FIRST;
      END IF;
   END;

   PROCEDURE setrow (nth IN PLS_INTEGER)
   IS
   BEGIN
      g_currrow := nth;
   END;

   FUNCTION getrow
      RETURN codeline_t
   IS
   BEGIN
      init_currrow;
      RETURN pkgarray (g_currrow);
   END;

   PROCEDURE nextrow
   IS
   BEGIN
      init_currrow;
      g_currrow := pkgarray.NEXT (g_currrow);
   END;

   PROCEDURE prevrow
   IS
   BEGIN
      init_currrow;
      g_currrow := pkgarray.PRIOR (g_currrow);
   END;

   PROCEDURE showrows (
      startrow   IN   PLS_INTEGER := NULL,
      endrow     IN   PLS_INTEGER := NULL
   )
   IS 
      v_start   PLS_INTEGER := NVL (startrow, 1);
      v_end     PLS_INTEGER := NVL (endrow, countrows);
   BEGIN
      FOR indx IN 1 .. countrows
      LOOP
         setrow (indx);
         utplsql.pl (getrow);
      END LOOP;
   END;

   -- TO COMPLETE: apply same output type flexibility
   -- from testpkg to receq_compare. 
   PROCEDURE putline (str IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (str);
   END;

-- 2.0.8 Implementation provided by Dan Spencer!
   PROCEDURE receq_package (
      table_in   IN   VARCHAR2,
      pkg_in     IN   VARCHAR2 := NULL,
      owner_in   IN   VARCHAR2 := NULL
   )
   IS 
      v_pkg     VARCHAR2 (30)
                         := NVL (pkg_in, SUBSTR ('receq_' || table_in, 1, 30));
      v_owner   VARCHAR2 (30) := UPPER (NVL (owner_in, USER));
      v_table   VARCHAR2 (30) := UPPER (table_in);
   BEGIN
      putline ('CREATE OR REPLACE PACKAGE ' || v_pkg || ' IS');

      FOR tabs_rec IN (SELECT *
                         FROM all_tables
                        WHERE owner = v_owner AND table_name = v_table)
      LOOP
         putline (
               'FUNCTION eq(a '
            || tabs_rec.table_name
            || '%ROWTYPE , b '
            || tabs_rec.table_name
            || '%ROWTYPE ) RETURN BOOLEAN; '
         );
      END LOOP;

      putline (' END ' || v_pkg || ';');
      putline ('/');
      putline (' ');
      putline ('CREATE OR REPLACE PACKAGE BODY ' || v_pkg || ' IS');

      FOR tabs_rec IN (SELECT *
                         FROM all_tables
                        WHERE owner = v_owner AND table_name = v_table)
      LOOP
         putline (
               'FUNCTION eq( a '
            || tabs_rec.table_name
            || '%ROWTYPE , '
            || 'b '
            || tabs_rec.table_name
            || '%ROWTYPE ) '
            || 'RETURN BOOLEAN '
         );
         putline ('IS BEGIN ');
         putline ('    RETURN (');

         FOR user_tab_columns_rec IN (SELECT   *
                                          FROM user_tab_columns
                                         WHERE table_name =
                                                          tabs_rec.table_name
                                      ORDER BY column_id)
         LOOP
            IF user_tab_columns_rec.column_id > 1
            THEN
               putline (' AND ');
            END IF;

            IF user_tab_columns_rec.data_type = 'CLOB'
            THEN
               putline (
                     '( ( a.'
                  || user_tab_columns_rec.column_name
                  || ' IS NULL AND  b.'
                  || user_tab_columns_rec.column_name
                  || ' IS NULL ) OR DBMS_LOB.COMPARE( a.'
                  || user_tab_columns_rec.column_name
                  || ' , b.'
                  || user_tab_columns_rec.column_name
                  || ') = 0 )'
               );
            ELSE
               putline (
                     '( ( a.'
                  || user_tab_columns_rec.column_name
                  || ' IS NULL AND  b.'
                  || user_tab_columns_rec.column_name
                  || ' IS NULL ) OR a.'
                  || user_tab_columns_rec.column_name
                  || ' = b.'
                  || user_tab_columns_rec.column_name
                  || ')'
               );
            END IF;
         END LOOP;

         putline ('); END eq;');
      END LOOP;

      putline (' END ' || v_pkg || ';');
      putline ('/');
      putline (' ');
   END;
END;
/
