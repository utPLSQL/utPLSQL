CREATE OR REPLACE PACKAGE BODY utplsql_util

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
Revision 1.4  2004/11/16 09:46:49  chrisrimmer
Changed to new version detection system.

Revision 1.3  2003/11/21 16:28:44  chrisrimmer
Fixed the commented out preprocessor flags, pointed out by Frank Puechl
in bug 846639

Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

AS 
   ver_no         VARCHAR2 (10) := '1.0.0';

   TYPE param_rec IS RECORD (
      col_name   VARCHAR2 (50),
      col_type   PLS_INTEGER,
      col_len    PLS_INTEGER,
      col_mode   PLS_INTEGER
   );

   TYPE params_tab IS TABLE OF param_rec
      INDEX BY BINARY_INTEGER;

   par_in         PLS_INTEGER   := 1;
   par_inout      PLS_INTEGER   := 2;
   par_out        PLS_INTEGER   := 3;
   param_prefix   VARCHAR2 (10) := 'ut_';

   FUNCTION get_version
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (ver_no);
   END;

   FUNCTION get_par_alias (par_type VARCHAR)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (par_type = 'VARCHAR')
      THEN
         RETURN ('vchar');
      ELSIF (par_type = 'NUMBER')
      THEN
         RETURN ('num');
      ELSIF (par_type = 'DATE')
      THEN
         RETURN ('date');
      ELSIF (par_type = 'REF CURSOR')
      THEN
         RETURN ('refc');
      ELSIF (par_type = 'CHAR')
      THEN
         RETURN ('chr');
      ELSE
         RETURN ('oth');
      END IF;
   END;

   PROCEDURE add_params (
      params         IN OUT   utplsql_params,
      par_pos                 PLS_INTEGER,
      par_type                VARCHAR2,
      par_sql_type            VARCHAR2,
      par_inout               PLS_INTEGER,
      par_val                 VARCHAR2
   )
   IS 
      idx   PLS_INTEGER;
   BEGIN
      idx := params.COUNT + 1;
      params (idx).par_name :=    param_prefix
                               || get_par_alias (par_type)
                               || '_'
                               || TO_CHAR (par_pos);
      params (idx).par_pos := par_pos;
      params (idx).par_type := par_type;
      params (idx).par_sql_type := par_sql_type;
      params (idx).par_inout := par_inout;
      params (idx).par_val := par_val;
   END;

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            VARCHAR2,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (params, par_pos, 'VARCHAR2', 'VARCHAR2', par_in, par_val);
   END;

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            NUMBER,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (
         params,
         par_pos,
         'NUMBER',
         'NUMBER',
         par_in,
         TO_CHAR (par_val)
      );
   END;

   PROCEDURE reg_in_array (
      par_pos      IN       PLS_INTEGER,
      array_name   IN       VARCHAR2,
      array_vals   IN       varchar_array,
      params       IN OUT   utplsql_params
   )
   IS 
      idx   PLS_INTEGER;
   BEGIN
      add_params (params, par_pos, 'ARRAY', array_name, par_in, NULL);
      idx := array_holder.COUNT + 1;

      FOR i IN 1 .. array_vals.COUNT
      LOOP
         array_holder (idx).array_pos := par_pos;
         array_holder (idx).array_val := array_vals (i);
         idx := idx + 1;
      END LOOP;
   END;

   PROCEDURE reg_in_param (
      par_pos            PLS_INTEGER,
      par_val            DATE,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (
         params,
         par_pos,
         'DATE',
         'DATE',
         par_in,
         TO_CHAR (par_val, 'DD-MON-YYYY:HH24:MI:SS')
      );
   END;

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            VARCHAR2,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (params, par_pos, 'VARCHAR2', 'VARCHAR2', par_inout, par_val);
   END;

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            NUMBER,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (
         params,
         par_pos,
         'NUMBER',
         'NUMBER',
         par_inout,
         TO_CHAR (par_val)
      );
   END;

   PROCEDURE reg_inout_param (
      par_pos            PLS_INTEGER,
      par_val            DATE,
      params    IN OUT   utplsql_params
   )
   IS
   BEGIN
      add_params (
         params,
         par_pos,
         'DATE',
         'DATE',
         par_inout,
         TO_CHAR (par_val, 'DD-MON-YYYY:HH24:MI:SS')
      );
   END;

   PROCEDURE reg_out_param (
      par_pos             PLS_INTEGER,
      par_type            VARCHAR2,
      params     IN OUT   utplsql_params
   )
   IS 
      int_par_type   VARCHAR2 (10);
   BEGIN
      IF (par_type = 'NUMBER')
      THEN
         int_par_type := 'NUMBER';
      ELSIF (par_type = 'VARCHAR')
      THEN
         int_par_type := 'VARCHAR2';
      ELSIF (par_type = 'CHAR')
      THEN
         int_par_type := 'VARCHAR2';
      ELSIF (par_type = 'REFCURSOR')
      THEN
         int_par_type := 'REFC';
      ELSE
         int_par_type := par_type;
      END IF;

      add_params (params, par_pos, int_par_type, int_par_type, par_out, NULL);
   END;

   FUNCTION strtoken (s_str IN OUT VARCHAR2, token VARCHAR2)
      RETURN VARCHAR2
   IS 
      pos      PLS_INTEGER;
      tmpstr   VARCHAR2 (4000);
   BEGIN
      pos := NVL (INSTR (s_str, token), 0);

      IF (pos = 0)
      THEN
         pos := LENGTH (s_str);
      END IF;

      tmpstr := SUBSTR (s_str, 1, pos);
      s_str := SUBSTR (s_str, pos);
      RETURN (tmpstr);
   END;

   PROCEDURE get_table_for_str (
      p_arr         OUT   v30_table,
      p_string            VARCHAR2,
      delim               VARCHAR2 := ',',
      enclose_str         VARCHAR2 DEFAULT NULL
   )
   IS 
      pos       INTEGER         := 1;
      v_idx     INTEGER         := 1;
      tmp_str   VARCHAR2 (4000);
   BEGIN
      IF p_string IS NULL
      THEN
         RETURN;
      END IF;

      tmp_str := p_string;

      LOOP
         EXIT WHEN (pos = 0);
         pos := INSTR (tmp_str, delim);

         IF (pos = 0)
         THEN
            p_arr (v_idx) := enclose_str || tmp_str || enclose_str;
         ELSE
            p_arr (v_idx) :=    enclose_str
                             || SUBSTR (tmp_str, 1, pos - 1)
                             || enclose_str;
            v_idx := v_idx + 1;
            tmp_str := SUBSTR (tmp_str, pos + 1);
         END IF;
      END LOOP;
   END;

   FUNCTION describe_proc (vproc_name VARCHAR2, params OUT params_tab)
      RETURN VARCHAR2
   IS 
      outstr           VARCHAR2 (3000)              := NULL;
      seperator        VARCHAR2 (10)                := NULL;
      v_overload       DBMS_DESCRIBE.number_table;
      v_position       DBMS_DESCRIBE.number_table;
      v_level          DBMS_DESCRIBE.number_table;
      v_argumentname   DBMS_DESCRIBE.varchar2_table;
      v_datatype       DBMS_DESCRIBE.number_table;
      v_defaultvalue   DBMS_DESCRIBE.number_table;
      v_inout          DBMS_DESCRIBE.number_table;
      v_length         DBMS_DESCRIBE.number_table;
      v_precision      DBMS_DESCRIBE.number_table;
      v_scale          DBMS_DESCRIBE.number_table;
      v_radix          DBMS_DESCRIBE.number_table;
      v_spare          DBMS_DESCRIBE.number_table;
      v_argcounter     PLS_INTEGER                  := 1;
      curr_level       PLS_INTEGER                  := 1;
      prev_level       PLS_INTEGER                  := 1;
      tab_open         BOOLEAN                      := FALSE ;
      rec_open         BOOLEAN                      := FALSE ;
      pos              PLS_INTEGER;

      PROCEDURE add_param (str VARCHAR2)
      IS 
         vtable   v30_table;
      BEGIN
         get_table_for_str (vtable, str, ':');

         IF (utplsql.tracing)
         THEN
            DBMS_OUTPUT.put_line (
                  'Parsed='
               || vtable (1)
               || ','
               || vtable (2)
               || ','
               || vtable (3)
               || ','
               || vtable (4)
            );
         END IF;

         params (pos).col_name := vtable (1);
         params (pos).col_type := vtable (2);
         params (pos).col_len := vtable (3);
         params (pos).col_mode := vtable (4);
         pos := pos + 1;
      END;
   BEGIN
      DBMS_DESCRIBE.describe_procedure (
         vproc_name,
         NULL,
         NULL,
         v_overload,
         v_position,
         v_level,
         v_argumentname,
         v_datatype,
         v_defaultvalue,
         v_inout,
         v_length,
         v_precision,
         v_scale,
         v_radix,
         v_spare
      );
      v_argcounter := 1;

      IF (v_position (1) = 0)
      THEN
         outstr := 'FUNCTION';
      ELSE
         outstr := 'PROCEDURE';
      END IF;

      pos := 1;

      LOOP
         IF (utplsql.tracing)
         THEN
            DBMS_OUTPUT.put_line (
                  'Desc()='
               || v_argumentname (v_argcounter)
               || ','
               || TO_CHAR (v_datatype (v_argcounter))
            );
         END IF;

         curr_level := v_level (v_argcounter);

         IF (utplsql.tracing)
         THEN
            DBMS_OUTPUT.put_line (
                  'Currlevel='
               || TO_CHAR (curr_level)
               || ',Prevlevel='
               || TO_CHAR (prev_level)
            );
         END IF;

         IF (curr_level <= prev_level)
         THEN
            IF (rec_open)
            THEN
               add_param ('RECORDEND:0:0:0');
               rec_open := FALSE ;
            ELSIF (tab_open)
            THEN
               add_param ('TABLEEND:0:0:0');
               tab_open := FALSE ;
            END IF;
         END IF;

         IF (v_datatype (v_argcounter) = 250)
         THEN                                                       /* Record */
            rec_open := TRUE ;
            add_param (
                  'RECORDBEGIN:'
               || TO_CHAR (v_datatype (v_argcounter))
               || ':'
               || TO_CHAR (v_length (v_argcounter))
               || ':'
               || TO_CHAR (v_inout (v_argcounter))
            );
            seperator := ',';
         ELSIF (v_datatype (v_argcounter) = 251)
         THEN                                                  /* PLSQL Table */
            tab_open := TRUE ;
            add_param (
                  'TABLEOPEN:'
               || TO_CHAR (v_datatype (v_argcounter))
               || ':'
               || TO_CHAR (v_length (v_argcounter))
               || ':'
               || TO_CHAR (v_inout (v_argcounter))
            );
         ELSIF (v_datatype (v_argcounter) = 102)
         THEN                                                   /* REF CURSOR */
            add_param (
                  'CURSOR:'
               || TO_CHAR (v_datatype (v_argcounter))
               || ':'
               || TO_CHAR (v_length (v_argcounter))
               || ':'
               || TO_CHAR (v_inout (v_argcounter))
            );
         ELSE
            add_param (
                  NVL (v_argumentname (v_argcounter), 'UNKNOWN')
               || ':'
               || TO_CHAR (v_datatype (v_argcounter))
               || ':'
               || TO_CHAR (v_length (v_argcounter))
               || ':'
               || TO_CHAR (v_inout (v_argcounter))
            );
         END IF;

         v_argcounter := v_argcounter + 1;
         seperator := ',';
      END LOOP;

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done DBMS_DESCRIBE');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         IF (rec_open)
         THEN
            add_param ('RECORDEND:0:0:0');
            rec_open := FALSE ;
         ELSIF (tab_open)
         THEN
            add_param ('TABLEEND:0:0:0');
            tab_open := FALSE ;
         END IF;

         RETURN (outstr);
      WHEN OTHERS
      THEN
         RAISE;
   END;

   PROCEDURE print_metadata (metadata sqldata_tab)
   IS
   BEGIN
      FOR i IN 1 .. NVL (metadata.COUNT, 0)
      LOOP
         DBMS_OUTPUT.put_line (
               'Name='
            || metadata (i).col_name
            || ',Type='
            || TO_CHAR (metadata (i).col_type)
            || ',Len='
            || TO_CHAR (metadata (i).col_len)
         );
      END LOOP;
   END;

   PROCEDURE get_metadata_for_cursor (
      proc_name         VARCHAR2,
      metadata    OUT   sqldata_tab
   )
   IS 
      params      params_tab;
      proc_type   VARCHAR2 (10);
      idx         PLS_INTEGER   := 1;
      pos         PLS_INTEGER   := 1;
   BEGIN
      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Start Describe Proc');
      END IF;

      proc_type := describe_proc (proc_name, params);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('End Describe Proc');
      END IF;

      --print_metadata(params);
      LOOP
         EXIT WHEN (params (pos).col_name = 'CURSOR');
         pos := pos + 1;
      END LOOP;

      pos := pos + 2;

      LOOP
         EXIT WHEN (params (pos).col_name = 'RECORDEND');
         metadata (idx).col_name := params (pos).col_name;
         metadata (idx).col_type := params (pos).col_type;
         metadata (idx).col_len := params (pos).col_len;
         idx := idx + 1;
         pos := pos + 1;
      END LOOP;
   END;

   PROCEDURE get_metadata_for_query (
      query_txt         VARCHAR2,
      metadata    OUT   sqldata_tab
   )
   IS 
      cols    DBMS_SQL.desc_tab;
      ncols   PLS_INTEGER;
      cur     INTEGER           := DBMS_SQL.open_cursor;
   BEGIN
      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Query=' || query_txt);
      END IF;

      DBMS_SQL.parse (cur, query_txt, DBMS_SQL.native);
      DBMS_SQL.describe_columns (cur, ncols, cols);

      FOR i IN 1 .. cols.COUNT
      LOOP
         metadata (i).col_name := cols (i).col_name;
         metadata (i).col_type := cols (i).col_type;
         metadata (i).col_len := cols (i).col_max_len;
      END LOOP;

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done get_metadata_for_query');
      END IF;
   END;

   PROCEDURE get_metadata_for_table (
      table_name         VARCHAR2,
      metadata     OUT   sqldata_tab
   )
   IS
   BEGIN
      get_metadata_for_query ('select * from ' || table_name, metadata);
   END;

   PROCEDURE get_metadata_for_proc (
      proc_name         VARCHAR2,
      POSITION          INTEGER,
      data_type   OUT   VARCHAR2,
      metadata    OUT   sqldata_tab
   )
   IS 
      outstr           VARCHAR2 (3000)              := NULL;
      seperator        VARCHAR2 (10)                := NULL;
      v_overload       DBMS_DESCRIBE.number_table;
      v_position       DBMS_DESCRIBE.number_table;
      v_level          DBMS_DESCRIBE.number_table;
      v_argumentname   DBMS_DESCRIBE.varchar2_table;
      v_datatype       DBMS_DESCRIBE.number_table;
      v_defaultvalue   DBMS_DESCRIBE.number_table;
      v_inout          DBMS_DESCRIBE.number_table;
      v_length         DBMS_DESCRIBE.number_table;
      v_precision      DBMS_DESCRIBE.number_table;
      v_scale          DBMS_DESCRIBE.number_table;
      v_radix          DBMS_DESCRIBE.number_table;
      v_spare          DBMS_DESCRIBE.number_table;
      v_argcounter     PLS_INTEGER                  := 1;
      curr_level       PLS_INTEGER                  := 1;
      prev_level       PLS_INTEGER                  := 1;
      tab_open         BOOLEAN                      := FALSE ;
      rec_open         BOOLEAN                      := FALSE ;
      pos              PLS_INTEGER;
      idx              PLS_INTEGER                  := 1;
      recs_copied      PLS_INTEGER;

      FUNCTION get_datatype (l_type INTEGER)
         RETURN VARCHAR2
      IS 
         r_type   VARCHAR2 (20);
      BEGIN
         -- Need to add more data types
         SELECT DECODE (
                   l_type,
                   1, 'VARCHAR2',
                   2, 'NUMBER',
                   12, 'DATE',
                   96, 'CHAR',
                   102, 'REF CURSOR',
                   250, 'RECORD',
                   251, 'PLSQL TABLE',
                   'UNKNOWN'
                )
           INTO r_type
           FROM DUAL;

         RETURN (r_type);
      END;

      PROCEDURE copy_metadata (l_idx INTEGER)
      IS 
         m_idx   INTEGER;
      BEGIN
         m_idx := metadata.COUNT + 1;
         metadata (m_idx).col_name := v_argumentname (l_idx);
         metadata (m_idx).col_type := v_datatype (l_idx);
         metadata (m_idx).col_len := v_length (l_idx);
      END;

      FUNCTION copy_level (l_idx INTEGER)
         RETURN INTEGER
      IS 
         l_counter   PLS_INTEGER := 1;
         l_level     PLS_INTEGER;
      BEGIN
         l_level := v_level (l_idx);
         l_counter := l_idx;

         LOOP
            EXIT WHEN (   (l_counter > v_argumentname.COUNT)
                       OR l_level <> v_level (l_counter)
                      );
            copy_metadata (l_counter);
            l_counter := l_counter + 1;
         END LOOP;

         RETURN (l_counter - l_idx);
      END;
   BEGIN
      DBMS_DESCRIBE.describe_procedure (
         proc_name,
         NULL,
         NULL,
         v_overload,
         v_position,
         v_level,
         v_argumentname,
         v_datatype,
         v_defaultvalue,
         v_inout,
         v_length,
         v_precision,
         v_scale,
         v_radix,
         v_spare
      );

      IF (v_position.COUNT = 0)
      THEN
         data_type := 'NOTFOUND';
         RETURN;
      END IF;

      idx := 1;

      LOOP
         EXIT WHEN (   ((v_level (idx) = 0) AND (POSITION = v_position (idx)))
                    OR (idx = v_position.COUNT)
                   );
         idx := idx + 1;
      END LOOP;

      IF (idx = v_position.COUNT)
      THEN
         IF (POSITION = v_position (idx))
         THEN
            data_type := get_datatype (v_datatype (idx));

            IF (data_type <> 'REF CURSOR')
            THEN -- Weak ref cursor
            copy_metadata (idx);
            END IF;
         ELSE
            data_type := 'NOTFOUND';
         END IF;

         RETURN;
      END IF;

      data_type := get_datatype (v_datatype (idx));

      --dbms_output.put_line('data_type = '||data_type||','||'Pos='||TO_CHAR(idx));

      IF (data_type = 'REF CURSOR')
      THEN
         IF (v_level (idx + 1) > v_level (idx))
         THEN -- Strong ref cursor
         idx := idx + 2;
         recs_copied := copy_level (idx);
         idx := idx + recs_copied;
         END IF;
      ELSIF (data_type = 'PLSQL TABLE')
      THEN
         IF (v_level (idx + 1) > v_level (idx))
         THEN
            IF (v_datatype (idx + 1) = 250)
            THEN -- RECORD
            idx := idx + 2; -- PLSQL TABLE OF RECORD (user defined)
            ELSE
               idx := idx + 1; -- PLSQL TABLE OF SINGLE COLUMN
            END IF;

            recs_copied := copy_level (idx);
            idx := idx + recs_copied;
         ELSE
            copy_metadata (idx);
         END IF;
      ELSIF (data_type = 'RECORD')
      THEN
         IF (v_level (idx + 1) > v_level (idx))
         THEN -- I think always true.
         idx := idx + 1;
         recs_copied := copy_level (idx);
         idx := idx + recs_copied;
         ELSE -- I guess it should never come here
         copy_metadata (idx);
         END IF;
      ELSE
         data_type := get_datatype (v_datatype (idx));
         copy_metadata (idx);
      END IF;
   END;

   PROCEDURE test_get_metadata_for_cursor (proc_name VARCHAR2)
   IS 
      metadata   sqldata_tab;
   BEGIN
      get_metadata_for_cursor (proc_name, metadata);

      IF (utplsql.tracing)
      THEN
         print_metadata (metadata);
      END IF;
   END;

   FUNCTION get_colnamesstr (metadata sqldata_tab)
      RETURN VARCHAR2
   IS 
      cnt   PLS_INTEGER;
      str   VARCHAR2 (32000);
   BEGIN
      cnt := metadata.COUNT;

      FOR i IN 1 .. cnt
      LOOP
         str := str || metadata (i).col_name || ',';
      END LOOP;

      RETURN (SUBSTR (str, 1, LENGTH (str) - 1));
   END;

   FUNCTION get_coltypesstr (metadata sqldata_tab)
      RETURN VARCHAR2
   IS 
      cnt   PLS_INTEGER;
      str   VARCHAR2 (2000);
   BEGIN
      cnt := metadata.COUNT;

      FOR i IN 1 .. cnt
      LOOP
         str := str || TO_CHAR (metadata (i).col_type) || ',';
      END LOOP;

      RETURN (SUBSTR (str, 1, LENGTH (str) - 1));
   END;

   FUNCTION get_coltype_syntax (col_type PLS_INTEGER, col_len PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (col_type = 1)
      THEN
         RETURN ('VARCHAR2(' || TO_CHAR (col_len) || ')');
      ELSIF (col_type = 2)
      THEN
         RETURN ('NUMBER');
      ELSIF (col_type = 12)
      THEN
         RETURN ('DATE');
      ELSIF (col_type = 96)
      THEN
         RETURN ('CHAR(' || TO_CHAR (col_len) || ')');
      END IF;
   END;

   FUNCTION get_coltype_syntax (col_type VARCHAR2, col_len PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (col_type = 'VARCHAR2')
      THEN
         RETURN ('VARCHAR2(' || TO_CHAR (col_len) || ')');
      ELSIF (col_type = 'NUMBER')
      THEN
         RETURN ('NUMBER');
      ELSIF (col_type = 'DATE')
      THEN
         RETURN ('DATE');
      ELSIF (col_type = 'CHAR')
      THEN
         RETURN ('CHAR(' || TO_CHAR (col_len) || ')');
      ELSIF (col_type = 'REFC')
      THEN
         RETURN ('REFC');
      ELSE
         RETURN (col_type);
      END IF;
   END;

   PROCEDURE PRINT (str VARCHAR2)
   IS 
      len   PLS_INTEGER;
   BEGIN
      len := LENGTH (str);

      FOR i IN 1 .. len
      LOOP
         DBMS_OUTPUT.put_line (SUBSTR (str, (i - 1) * 255, 255));
      END LOOP;

      IF ((len * 255) > LENGTH (str))
      THEN
         DBMS_OUTPUT.put_line (SUBSTR (str, len * 255));
      END IF;
   END;

   FUNCTION get_proc_name (p_proc_nm VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (SUBSTR (p_proc_nm, 1, INSTR (p_proc_nm, '(') - 1));
   END;

   FUNCTION get_val_for_table (
      table_name         VARCHAR2,
      col_name           VARCHAR2,
      col_val      OUT   VARCHAR2,
      col_type     OUT   NUMBER
   )
      RETURN NUMBER
   IS 
      cur        PLS_INTEGER       := DBMS_SQL.open_cursor;
      cols       DBMS_SQL.desc_tab;
      ncols      PLS_INTEGER;
      idx        PLS_INTEGER       := 0;
      tvarchar   VARCHAR2 (4000);
      tchar      CHAR (4000);
      tdate      DATE;
      tnumber    NUMBER;
      stmt       VARCHAR2 (200);
      vresult    PLS_INTEGER;
   BEGIN
      stmt := 'select * from ' || table_name;
      DBMS_SQL.parse (cur, stmt, DBMS_SQL.native);
      DBMS_SQL.describe_columns (cur, ncols, cols);

      FOR i IN 1 .. cols.COUNT
      LOOP
         IF (cols (i).col_type = 1)
         THEN
            DBMS_SQL.define_column (cur, i, tvarchar, cols (i).col_max_len);
         ELSIF (cols (i).col_type = 2)
         THEN
            DBMS_SQL.define_column (cur, i, tnumber);
         ELSIF (cols (i).col_type = 12)
         THEN
            DBMS_SQL.define_column (cur, i, tdate);
         ELSIF (cols (i).col_type = 96)
         THEN
            DBMS_SQL.define_column (cur, i, tchar, cols (i).col_max_len);
         ELSE
            raise_application_error (-20000, 'UNSUPPORTED COLUMN TYPE');
         END IF;

         IF (cols (i).col_name = col_name)
         THEN
            idx := i;
         END IF;
      END LOOP;

      IF (idx = 0)
      THEN
         RETURN (-1);
      END IF;

      vresult := DBMS_SQL.EXECUTE (cur);

      IF (DBMS_SQL.fetch_rows (cur) = 0)
      THEN
         RETURN (1);
      END IF;

      IF (cols (idx).col_type = 1)
      THEN
         DBMS_SQL.column_value (cur, idx, tvarchar);
         col_val := tvarchar;
      ELSIF (cols (idx).col_type = 2)
      THEN
         DBMS_SQL.column_value (cur, idx, tnumber);
         col_val := TO_CHAR (tnumber);
      ELSIF (cols (idx).col_type = 12)
      THEN
         DBMS_SQL.column_value (cur, idx, tdate);
         col_val := TO_CHAR (tdate, 'DD-MON-YYYY:HH24:MI:SS');
      ELSIF (cols (idx).col_type = 96)
      THEN
         DBMS_SQL.column_value (cur, idx, tchar);
         col_val := tchar;
      END IF;

      col_type := cols (idx).col_type;
      DBMS_SQL.close_cursor (cur);
      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_table_name
      RETURN VARCHAR2
   IS 
      tmp_seq     NUMBER;
      curr_user   VARCHAR2 (20);
   BEGIN
      SELECT SYS_CONTEXT ('USERENV', 'CURRENT_USER')
        INTO curr_user
        FROM DUAL;

      SELECT ut_refcursor_results_seq.NEXTVAL
        INTO tmp_seq
        FROM DUAL;

      --RETURN('utplsql_temp_'||tmp_seq);
      RETURN (curr_user || '.' || 'UTPLSQL_TEMP_' || tmp_seq);
   END;

   PROCEDURE execute_ddl (stmt VARCHAR2)
   IS 
      &start_lt_8_1
      fdbk   PLS_INTEGER;
      cur    PLS_INTEGER := DBMS_SQL.open_cursor;
      &end_lt_8_1
   BEGIN
      &start_ge_8_1
      EXECUTE IMMEDIATE stmt;
      &start_ge_8_1
      &start_lt_8_1
      DBMS_SQL.parse (cur, stmt, DBMS_SQL.native);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.close_cursor (cur);
      &end_lt_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END;

   FUNCTION get_create_ddl (
      metadata     utplsql_util.sqldata_tab,
      table_name   VARCHAR2,
      owner_name   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS 
      ddl_stmt   VARCHAR2 (5000);
      cnt        PLS_INTEGER;
   BEGIN
      IF (NVL (metadata.COUNT, 0) = 0)
      THEN
         RETURN (NULL);
      END IF;

      --ddl_stmt := 'create table '||NVL(owner_name,'UTPLSQL')||'.'||table_name||' ( ';
      ddl_stmt := 'create table ' || table_name || ' ( ';

      FOR i IN 1 .. metadata.COUNT
      LOOP
         ddl_stmt :=    ddl_stmt
                     || metadata (i).col_name
                     || ' '
                     || utplsql_util.get_coltype_syntax (
                           metadata (i).col_type,
                           metadata (i).col_len
                        )
                     || ',';
      END LOOP;

      ddl_stmt := SUBSTR (ddl_stmt, 1, LENGTH (ddl_stmt) - 1) || ')';

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Current user = ' || USER);
         utplsql_util.PRINT (ddl_stmt);
      END IF;

      RETURN (ddl_stmt);
   END;

   PROCEDURE prepare_cursor_1 (
      stmt             IN OUT   VARCHAR2,
      table_name                VARCHAR2,
      call_proc_name            VARCHAR2,
      metadata                  utplsql_util.sqldata_tab
   )
   IS 
      col_str   VARCHAR2 (200);
   BEGIN
      IF (NVL (metadata.COUNT, 0) = 0)
      THEN
         RETURN;
      END IF;

      stmt :=
         'declare
             p_result_id   PLS_INTEGER;
             p_rec_nm      PLS_INTEGER := 0;
             TYPE refc is ref cursor;
             rc refc;';

      FOR i IN 1 .. metadata.COUNT
      LOOP
         stmt :=    stmt
                 || metadata (i).col_name
                 || ' '
                 || utplsql_util.get_coltype_syntax (
                       metadata (i).col_type,
                       metadata (i).col_len
                    )
                 || ';'
                 || CHR (10);
      END LOOP;

      col_str := utplsql_util.get_colnamesstr (metadata);
      stmt :=
            stmt
         || 'BEGIN
          rc := '
         || call_proc_name
         || ';
          LOOP
             FETCH rc INTO '
         || col_str
         || ';
             EXIT WHEN rc%NOTFOUND;
             p_rec_nm := p_rec_nm + 1;
             INSERT INTO '
         || table_name
         || ' ('
         || col_str
         || ')'
         || ' values ('
         || col_str
         || ');'
         || '
             END LOOP;
             CLOSE rc;
         END;';

      IF (utplsql.tracing)
      THEN
         utplsql_util.PRINT (stmt);
      END IF;
   END;

   FUNCTION get_par_for_decl (params utplsql_params)
      RETURN VARCHAR2
   IS 
      decl   VARCHAR2 (1000);
   BEGIN
      FOR i IN 1 .. params.COUNT
      LOOP
         decl :=    decl
                 || params (i).par_name
                 || ' '
                 || utplsql_util.get_coltype_syntax (
                       params (i).par_sql_type,
                       1000
                    )
                 || ';'
                 || CHR (10);
      END LOOP;

      RETURN (decl);
   END;

   FUNCTION get_param_valstr (params utplsql_params, POSITION PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      IF (params (POSITION).par_type = 'DATE')
      THEN
         RETURN (   'TO_DATE('''
                 || params (POSITION).par_val
                 || ''',''DD-MON-YYYY:HH24:MI:SS'')'
                );
      ELSE
         RETURN ('''' || params (POSITION).par_val || '''');
      END IF;
   END;

   FUNCTION get_param_valstr_from_array (
      params      utplsql_params,
      POSITION    PLS_INTEGER,
      array_pos   PLS_INTEGER
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF (params (POSITION).par_type = 'DATE')
      THEN
         RETURN (   'TO_DATE('''
                 || array_holder (array_pos).array_val
                 || ''',''DD-MON-YYYY:HH24:MI:SS'')'
                );
      ELSE
         RETURN ('''' || array_holder (array_pos).array_val || '''');
      END IF;
   END;

   PROCEDURE print_utplsql_params (params utplsql_params)
   IS
   BEGIN
      FOR i IN 1 .. params.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
               'Name='
            || params (i).par_name
            || ',type='
            || params (i).par_type
            || ',mode='
            || TO_CHAR (params (i).par_inout)
            || ',pos='
            || TO_CHAR (params (i).par_pos)
            || ',val='
            || params (i).par_val
         );
      END LOOP;
   END;

   PROCEDURE init_array_holder
   IS
   BEGIN
      array_holder.DELETE;
   END;

   PROCEDURE print_array_holder
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('Printing array holder');

      FOR i IN 1 .. array_holder.COUNT
      LOOP
         DBMS_OUTPUT.put_line ('pos=' || TO_CHAR (array_holder (i).array_pos));
         PRINT ('Val=' || array_holder (i).array_val);
      END LOOP;
   END;

   FUNCTION get_index_for_array (pos INTEGER)
      RETURN INTEGER
   IS 
      idx   PLS_INTEGER := 1;
   BEGIN
      LOOP
         EXIT WHEN (array_holder (idx).array_pos = pos);
         idx := idx + 1;
      END LOOP;

      RETURN (idx);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN (-1);
   END;

   FUNCTION get_par_for_assign (params utplsql_params)
      RETURN VARCHAR2
   IS 
      assign      VARCHAR2 (1000);
      array_idx   PLS_INTEGER;
      idx         PLS_INTEGER     := 1;
   BEGIN
      IF (utplsql.tracing)
      THEN
         print_array_holder;
      END IF;

      FOR i IN 1 .. params.COUNT
      LOOP
         IF (params (i).par_inout != par_out)
         THEN
            IF (utplsql.tracing)
            THEN
               DBMS_OUTPUT.put_line (
                  'In get_par_for_assign<' || params (i).par_type || '>'
               );
            END IF;

            IF (params (i).par_type != 'ARRAY')
            THEN
               assign :=    assign
                         || params (i).par_name
                         || ' := '
                         || get_param_valstr (params, i)
                         || ';'
                         || CHR (10);
            ELSE
               array_idx := get_index_for_array (params (i).par_pos);

               IF (utplsql.tracing)
               THEN
                  DBMS_OUTPUT.put_line ('start index =' || TO_CHAR (
                                                              array_idx
                                                           ));
               END IF;

               LOOP
                  BEGIN
                     EXIT WHEN array_holder (array_idx).array_pos !=
                                                           params (i).par_pos;
                     assign :=    assign
                               || params (i).par_name
                               || '('
                               || TO_CHAR (idx)
                               || ') := '
                               || get_param_valstr_from_array (
                                     params,
                                     i,
                                     array_idx
                                  )
                               || ';'
                               || CHR (10);
                     array_idx := array_idx + 1;
                     idx := idx + 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        EXIT;
                  END;
               END LOOP;
            END IF;
         END IF;
      END LOOP;

      RETURN (assign);
   END;

   FUNCTION get_par_for_call (params utplsql_params, proc_name VARCHAR2)
      RETURN VARCHAR2
   IS 
      call_str    VARCHAR2 (1000);
      start_idx   PLS_INTEGER;
   BEGIN
      IF (params (1).par_pos = 0)
      THEN
         call_str := params (1).par_name || ' := ' || proc_name || '(';
         start_idx := 2;
      ELSE
         call_str := proc_name || '(';
         start_idx := 1;
      END IF;

      FOR i IN start_idx .. params.COUNT
      LOOP
         IF (i != start_idx)
         THEN
            call_str := call_str || ',' || params (i).par_name;
         ELSE
            call_str := call_str || params (i).par_name;
         END IF;
      END LOOP;

      call_str := call_str || ')';
      RETURN (call_str);
   END;

   PROCEDURE get_single_param (
      params                  utplsql_params,
      POSITION                PLS_INTEGER,
      single_param   IN OUT   params_rec
   )
   IS 
      idx   PLS_INTEGER;
   BEGIN
      IF (POSITION != 0)
      THEN
         IF (params (1).par_pos = 0)
         THEN
            idx := POSITION + 1;
         ELSE
            idx := POSITION;
         END IF;
      ELSE
         idx := POSITION + 1;
      END IF;

      single_param.par_name := params (idx).par_name;
      single_param.par_type := params (idx).par_type;
      single_param.par_val := params (idx).par_val;
      single_param.par_inout := params (idx).par_inout;
   END;

   PROCEDURE prepare_cursor_100 (
      stmt             IN OUT   VARCHAR2,
      table_name                VARCHAR2,
      call_proc_name            VARCHAR2,
      POSITION                  PLS_INTEGER,
      metadata                  utplsql_util.sqldata_tab,
      params                    utplsql_params
   )
   IS 
      col_str        VARCHAR2 (32000);
      single_param   params_rec;
   BEGIN
      IF (NVL (metadata.COUNT, 0) = 0)
      THEN
         RETURN;
      END IF;

      stmt :=
         'declare
             p_result_id   PLS_INTEGER;
             p_rec_nm      PLS_INTEGER := 0;
             TYPE refc is ref cursor;
             rc refc;';

      FOR i IN 1 .. metadata.COUNT
      LOOP
         stmt :=    stmt
                 || metadata (i).col_name
                 || ' '
                 || utplsql_util.get_coltype_syntax (
                       metadata (i).col_type,
                       metadata (i).col_len
                    )
                 || ';'
                 || CHR (10);
      END LOOP;

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done ref cursor column declarations');
      END IF;

      stmt := stmt || get_par_for_decl (params);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done params declarations');
      END IF;

      get_single_param (params, POSITION, single_param);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done get_single_param');
      END IF;

      col_str := utplsql_util.get_colnamesstr (metadata);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done get_colnamesstr');
      END IF;

      stmt :=
            stmt
         || 'BEGIN
          '
         || get_par_for_assign (params)
         || '
          '
         || get_par_for_call (params, call_proc_name)
         || ';
          LOOP
             FETCH '
         || single_param.par_name
         || ' INTO '
         || col_str
         || ';
             EXIT WHEN '
         || single_param.par_name
         || '%NOTFOUND;
             p_rec_nm := p_rec_nm + 1;
             INSERT INTO '
         || table_name
         || ' ('
         || col_str
         || ')'
         || ' values ('
         || col_str
         || ');'
         || '
             END LOOP;
             CLOSE '
         || single_param.par_name
         || ';
         END;';

      IF (utplsql.tracing)
      THEN
         utplsql_util.PRINT (stmt);
      END IF;

      init_array_holder;
   END;

   FUNCTION prepare_and_fetch_rc (proc_name VARCHAR2)
      RETURN VARCHAR2
   IS 
      vproc_nm     VARCHAR2 (50);
      metadata     utplsql_util.sqldata_tab;
      stmt         VARCHAR2 (32000);
      table_name   VARCHAR2 (20);
   BEGIN
      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Call=' || proc_name);
      END IF;

      vproc_nm := utplsql_util.get_proc_name (proc_name);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Proc Name=' || vproc_nm);
      END IF;

      utplsql_util.get_metadata_for_cursor (vproc_nm, metadata);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Metadata Done');
      END IF;

      table_name := get_table_name ();

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Refcursor Table Name=' || table_name);
      END IF;

      stmt := get_create_ddl (metadata, table_name);

      IF (utplsql.tracing)
      THEN
         utplsql_util.PRINT ('Create ddl=' || stmt);
      END IF;

      execute_ddl (stmt);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Table created');
      END IF;

      IF (NVL (metadata.COUNT, 0) = 0)
      THEN
         RETURN (NULL);
      END IF;

      --prepare_cursor_1(stmt,'UTPLSQL'||'.'||table_name,proc_name,metadata);
      prepare_cursor_1 (stmt, table_name, proc_name, metadata);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done  prepare_cursor_1');
      END IF;

      execute_ddl (stmt);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done execute_ddl');
      END IF;

      --RETURN(USER||'.'||table_name);
      RETURN (table_name);
   END;

   FUNCTION prepare_and_fetch_rc (
      proc_name            VARCHAR2,
      params               utplsql_params,
      refc_pos_in_proc     PLS_INTEGER,
      refc_metadata_from   PLS_INTEGER DEFAULT 1,
      refc_metadata_str    VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS 
      metadata     utplsql_util.sqldata_tab;
      stmt         VARCHAR2 (32000);
      table_name   VARCHAR2 (50);
      datatype     VARCHAR2 (20);
   BEGIN
      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('In prepare_and_fetch_rc ');
         DBMS_OUTPUT.put_line ('proc name        =' || proc_name);
         print_utplsql_params (params);
         DBMS_OUTPUT.put_line ('Method=' || TO_CHAR (refc_metadata_from));
         PRINT ('refc_metadata_str=' || refc_metadata_str);
         --dbms_output.put_line('refc_metadata_str='||refc_metadata_str);
         DBMS_OUTPUT.put_line ('Position=' || TO_CHAR (refc_pos_in_proc));
      END IF;

      utplsql_util.get_metadata_for_proc (
         proc_name,
         refc_pos_in_proc,
         datatype,
         metadata
      );

      IF (metadata.COUNT = 0)
      THEN
         IF (utplsql.tracing)
         THEN
            DBMS_OUTPUT.put_line ('Weak ref cursor');
         END IF;

         IF (refc_metadata_from = 1)
         THEN
            utplsql_util.get_metadata_for_table (refc_metadata_str, metadata);
         ELSIF (refc_metadata_from = 2)
         THEN
            utplsql_util.get_metadata_for_query (refc_metadata_str, metadata);
         END IF;
      END IF;

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done metadata');
      END IF;

      IF (metadata.COUNT = 0)
      THEN
         DBMS_OUTPUT.put_line ('ERROR: metadata  is null');
         RETURN (NULL);
      END IF;

      table_name := get_table_name ();

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Refcursor Table Name=' || table_name);
      END IF;

      stmt := get_create_ddl (metadata, table_name);

      IF (utplsql.tracing)
      THEN
         utplsql_util.PRINT ('Create ddl=' || stmt);
      END IF;

      execute_ddl (stmt);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Table created');
      END IF;

      IF (NVL (metadata.COUNT, 0) = 0)
      THEN
         RETURN (NULL);
      END IF;

      --prepare_cursor_100(stmt,'UTPLSQL'||'.'||table_name,proc_name,refc_pos_in_proc,metadata,params);
      prepare_cursor_100 (
         stmt,
         table_name,
         proc_name,
         refc_pos_in_proc,
         metadata,
         params
      );

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done  prepare_cursor_1');
      END IF;

      execute_ddl (stmt);

      IF (utplsql.tracing)
      THEN
         DBMS_OUTPUT.put_line ('Done  execute_ddl');
      END IF;

      --RETURN(USER||'.'||table_name);
      RETURN (table_name);
   END;
END;
/
