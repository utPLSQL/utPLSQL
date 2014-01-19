/* Formatted by PL/Formatter v3.0.5.0 on 2000/06/30 20:52 */

CREATE OR REPLACE PACKAGE BODY utassert
IS
/* 
GNU General Public License for utPLSQL
    
Copyright (C) 2000 
Steven Feuerstein, steven@stevenfeuerstein.com
Chris Rimmer, chris@sunset.force9.co.uk

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

   g_showresults BOOLEAN := FALSE;
   
   -- DBMS_PIPE functionality based on code provided by John Beresniewicz, 
   -- Savant Corp, in ORACLE BUILT-IN PACKAGES

   -- For pipe equality checking
   TYPE msg_rectype IS RECORD(
   
      item_type INTEGER,
      mvc2      VARCHAR2 (4093),
      mdt       DATE,
      mnum      NUMBER,
      mrid      ROWID,
      mraw      RAW (4093));

   /*
   || msg_tbltype tables can hold an ordered list of
   || message items, thus any message can be captured
   */
   TYPE msg_tbltype IS TABLE OF msg_rectype
      INDEX BY BINARY_INTEGER;

   FUNCTION expected (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (
                msg_in || '; expected "' || against_this_in ||
                   '", got "' ||
                   check_this_in ||
                   '"'
             );
   END;

   PROCEDURE this (
      msg_in IN VARCHAR2,
      check_this_in IN BOOLEAN,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE,
      register_in IN BOOLEAN := TRUE
      )
   IS
   BEGIN
      IF utplsql.tracing
      THEN
         utplsql.pl ('utPLSQL TRACE on Assert: ' || msg_in);
         utplsql.bpl (check_this_in);
      END IF;

      IF    NOT check_this_in
         OR (    check_this_in IS NULL
             AND NOT null_ok_in)
      THEN
         IF register_in
         THEN
            utresult.report (msg_in);
         ELSE
            utplsql.pl (msg_in);
         END IF;
         
         IF showing_results AND register_in
         THEN
            utresult.showlast;
         END IF;

         IF raise_exc_in
         THEN
            RAISE test_failure;
         END IF;
      END IF;
   END;

   PROCEDURE eq (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      IF utplsql.tracing
      THEN
         utplsql.pl (
            'Compare "' || check_this_in || '" to "' ||
               against_this_in ||
               '"'
         );
      END IF;

      this (
         expected (msg_in, check_this_in, against_this_in),
         check_this_in = against_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   FUNCTION b2v (bool_in IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF bool_in
      THEN
         RETURN 'TRUE';
      ELSIF NOT bool_in
      THEN
         RETURN 'FALSE';
      ELSE
         RETURN 'NULL';
      END IF;
   END;

   PROCEDURE eq (
      msg_in IN VARCHAR2,
      check_this_in IN BOOLEAN,
      against_this_in IN BOOLEAN,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         expected (
            msg_in,
            b2v (check_this_in),
            b2v (against_this_in)
         ),
         b2v (check_this_in) = b2v (against_this_in),
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      msg_in IN VARCHAR2,
      check_this_in IN DATE,
      against_this_in IN DATE,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE,
      truncate_in IN BOOLEAN := FALSE
   )
   IS
      c_format CONSTANT VARCHAR2 (30)
               := 'MONTH DD, YYYY HH24MISS';
      v_check VARCHAR2 (100);
      v_against VARCHAR2 (100);
   BEGIN
      IF truncate_in
      THEN
         v_check :=
                  TO_CHAR (TRUNC (check_this_in), c_format);
         v_against :=
                TO_CHAR (TRUNC (against_this_in), c_format);
      ELSE
         v_check := TO_CHAR (check_this_in, c_format);
         v_against := TO_CHAR (against_this_in, c_format);
      END IF;

      this (
         expected (msg_in, v_check, v_against),
         v_check = v_against,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE ieqminus (
      msg_in IN VARCHAR2,
      query1_in IN VARCHAR2,
      query2_in IN VARCHAR2,
      minus_desc_in IN VARCHAR2,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
/*
Recommendation from Solomon to handle duplicates:
(NOT YET IMPLEMENTED)
SELECT table1.*,count(*)

  FROM table1

 GROUP BY column1,column2,...
MINUS
SELECT table2.*,count(*)

  FROM table2

 GROUP BY column1,column2,...
and 
SELECT table2.*,count(*)

  FROM table2

 GROUP BY column1,column2,...
MINUS
SELECT table1.*,count(*)

  FROM table1

 GROUP BY column1,column2,... 
*/
      &start73 
      fdbk PLS_INTEGER; 
      cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR; 
      &end73
      ival PLS_INTEGER;
      v_block VARCHAR2 (32767)
         := 'DECLARE
         CURSOR cur IS (' || query1_in ||
               ' MINUS ' ||
               query2_in ||
               ')
        UNION 
        (' ||
               query2_in ||
               ' MINUS ' ||
               query1_in ||
               ');
          rec cur%ROWTYPE;
       BEGIN     
          OPEN cur;
          FETCH cur INTO rec;
          IF cur%FOUND THEN :retval := 1;
          ELSE :retval := 0;
          END IF;
          CLOSE cur;
       END;';
   BEGIN
      &start81
      EXECUTE IMMEDIATE v_block
         USING  OUT ival;
      &end81
      &start73
      DBMS_SQL.PARSE (cur, v_block, DBMS_SQL.NATIVE);
      DBMS_SQL.BIND_VARIABLE (cur, ':retval', ival); -- 1.5.6
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.VARIABLE_VALUE (cur, 'retval', ival);
      DBMS_SQL.CLOSE_CURSOR (cur);
      &end73

      this (
         expected (
            minus_desc_in || ' ' || msg_in,
            query1_in,
            query2_in
         ),
         ival = 0,
         FALSE,
         raise_exc_in
      );
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.CLOSE_CURSOR (cur);
         &end73
         
         utplsql.pl (
            'IeqMinus error ' || SQLCODE || ' for "' ||
               v_block ||
               '"'
         );
         RAISE;
   END;

   PROCEDURE eqtable (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      check_where_in IN VARCHAR2 := NULL,
      against_where_in IN VARCHAR2 := NULL,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      ival PLS_INTEGER;
   BEGIN
      ieqminus (
         msg_in,
         'SELECT * FROM ' || check_this_in || '  WHERE ' ||
            NVL (check_where_in, '1=1'),
         'SELECT * FROM ' || against_this_in || '  WHERE ' ||
            NVL (against_where_in, '1=1'),
         'Table Equality',
         raise_exc_in
      );
   END;

   PROCEDURE eqtabcount (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      check_where_in IN VARCHAR2 := NULL,
      against_where_in IN VARCHAR2 := NULL,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      ival PLS_INTEGER;
   BEGIN
      ieqminus (
         msg_in,
         'SELECT COUNT(*) FROM ' || check_this_in ||
            '  WHERE ' ||
            NVL (check_where_in, '1=1'),
         'SELECT COUNT(*) FROM ' || against_this_in ||
            '  WHERE ' ||
            NVL (against_where_in, '1=1'),
         'Table Count Equality',
         raise_exc_in
      );
   END;

   PROCEDURE eqquery (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      -- User passes in two SELECT statements. Use NDS to minus them.
      ival PLS_INTEGER;
   BEGIN
      ieqminus (
         msg_in,
         check_this_in,
         against_this_in,
         'Query Equality',
         raise_exc_in
      );
   END;

   --Check a query against a single value
   PROCEDURE iqueryvalue (
      msg_in IN VARCHAR2,
      declare_in IN VARCHAR2,
      check_query_in IN VARCHAR2,
      raise_exc_in BOOLEAN
   )
   IS
      v_block VARCHAR2 (32767) := 
         'DECLARE ' || declare_in || '
         CURSOR cur IS (' || check_query_in || ');
      BEGIN
         --Open the cursor
         OPEN cur;

         --Fetch into our variable
         FETCH cur INTO v_out;

         --Compare against what we expected
         utAssert.eq (msg_in => ''' || msg_in || ''',
                      check_this_in => v_out, 
                      against_this_in => v_exp,
                      raise_exc_in => ' || b2v(raise_exc_in) || ');

         --Try to fetch again
         FETCH cur INTO v_out;

         --If we found something, that is a problem
         IF cur%FOUND THEN
            utAssert.this (msg_in => ''' || msg_in || ''' || ''; Got multiple values'', 
                           check_this_in => FALSE,
                           raise_exc_in => ' || b2v(raise_exc_in) || ');
         END IF;
        
         --Close the cursor 
         CLOSE cur;
      END;';
      &start73
      dyn_cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
      ret_val PLS_INTEGER;
      &end73
   BEGIN

      --Fire off the dynamic PL/SQL
      &start81
      EXECUTE IMMEDIATE v_block;
      &end81
      &start73
         DBMS_SQL.PARSE (dyn_cur, v_block, DBMS_SQL.NATIVE);

        ret_val := DBMS_SQL.EXECUTE (dyn_cur);
        DBMS_SQL.CLOSE_CURSOR (dyn_cur);
      &end73

   END;


   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      msg_in IN VARCHAR2,
      check_query_in IN VARCHAR2,
      against_value_in IN VARCHAR2,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      v_declare VARCHAR2 (32767) := 
         'v_out VARCHAR2(4000);
         v_exp VARCHAR2(4000) := ''' || against_value_in || ''';';
   BEGIN

      iqueryvalue (msg_in,
                   v_declare,
                   check_query_in,
                   raise_exc_in);

   END;

   -- Check a query against a single DATE value
   PROCEDURE eqqueryvalue (
      msg_in IN VARCHAR2,
      check_query_in IN VARCHAR2,
      against_value_in IN DATE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
        v_declare VARCHAR2 (32767) := 
         'v_out DATE;
         v_exp DATE := TO_DATE(''' || TO_CHAR(against_value_in, 'DDMMYYYY HH24MISS') || ''', ''DDMMYYYY HH24MISS'');';
   BEGIN

      iqueryvalue (msg_in,
                   v_declare,
                   check_query_in,
                   raise_exc_in);

   END;

   PROCEDURE eqcursor (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      raise_exc_in IN BOOLEAN := FALSE
   )
   -- User passes in names of two packaged cursors.
   -- Have to loop through each row and compare!
   -- How do I compare the contents of two records
   -- which have been defined dynamically?
   IS
   BEGIN
      utplsql.pl (
         'utAssert.eqCursor is not yet implemented!'
      );
   END;

   PROCEDURE eqfile (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      check_this_dir_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      against_this_dir_in IN VARCHAR2 := NULL,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      checkid UTL_FILE.file_type;
      againstid UTL_FILE.file_type;
      samefiles BOOLEAN := TRUE;
      checkline VARCHAR2 (32767);
      againstline VARCHAR2 (32767);
      check_eof BOOLEAN;
      against_eof BOOLEAN;

      PROCEDURE cleanup (val IN BOOLEAN)
      IS
      BEGIN
         UTL_FILE.fclose (checkid);
         UTL_FILE.fclose (againstid);
         this (
            'Files equal? Compared "' || check_this_in ||
               '" against "' ||
               against_this_in ||
               '"',
            val,
            FALSE,
            raise_exc_in
         );
      END;
   BEGIN
      -- Compare contents of two files.
      checkid :=
        UTL_FILE.fopen (
           check_this_dir_in,
           check_this_in,
           'R'
           &start81, max_linesize => 32767 &end81
        );
      againstid :=
        UTL_FILE.fopen (
           NVL (against_this_dir_in, check_this_dir_in),
           against_this_in,
           'R'
           &start81, max_linesize => 32767 &end81
        );

      LOOP
         BEGIN
            UTL_FILE.get_line (checkid, checkline);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               check_eof := TRUE;
         END;

         BEGIN
            UTL_FILE.get_line (againstid, againstline);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               against_eof := TRUE;
         END;

         IF (    check_eof
             AND against_eof)
         THEN
            samefiles := TRUE;
            EXIT;
         ELSIF (checkline != againstline)
         THEN
            samefiles := FALSE;
            EXIT;
         ELSIF (   check_eof
                OR against_eof)
         THEN
            samefiles := FALSE;
            EXIT;
         END IF;
      END LOOP;

      cleanup (samefiles);
   EXCEPTION
      WHEN OTHERS
      THEN
         cleanup (FALSE);
   END;

   PROCEDURE receive_and_unpack (
      pipe_in IN VARCHAR2,
      msg_tbl_out OUT msg_tbltype,
      pipe_status_out IN OUT PLS_INTEGER
   )
   IS
      invalid_item_type EXCEPTION;
      null_msg_tbl msg_tbltype;
      next_item INTEGER;
      item_count INTEGER := 0;
   BEGIN
      pipe_status_out :=
          DBMS_PIPE.receive_message (pipe_in, timeout => 0);

      IF pipe_status_out != 0
      THEN
         RAISE invalid_item_type;
      END IF;

      LOOP
         next_item := DBMS_PIPE.next_item_type;
         EXIT WHEN next_item = 0;
         item_count := item_count + 1;
         msg_tbl_out (item_count).item_type := next_item;

         IF next_item = 9
         THEN
            DBMS_PIPE.unpack_message (
               msg_tbl_out (item_count).mvc2
            );
         ELSIF next_item = 6
         THEN
            DBMS_PIPE.unpack_message (
               msg_tbl_out (item_count).mnum
            );
         ELSIF next_item = 11
         THEN
            DBMS_PIPE.unpack_message_rowid (
               msg_tbl_out (item_count).mrid
            );
         ELSIF next_item = 12
         THEN
            DBMS_PIPE.unpack_message (
               msg_tbl_out (item_count).mdt
            );
         ELSIF next_item = 23
         THEN
            DBMS_PIPE.unpack_message_raw (
               msg_tbl_out (item_count).mraw
            );
         ELSE
            RAISE invalid_item_type;
         END IF;

         next_item := DBMS_PIPE.next_item_type;
      END LOOP;
   EXCEPTION
      WHEN invalid_item_type
      THEN
         msg_tbl_out := null_msg_tbl;
   END receive_and_unpack;

   PROCEDURE compare_pipe_tabs (
      tab1 msg_tbltype,
      tab2 msg_tbltype,
      same_out IN OUT BOOLEAN
   )
   IS
      indx PLS_INTEGER := tab1.FIRST;
   BEGIN
      LOOP
         EXIT WHEN indx IS NULL;

         BEGIN
            IF tab1 (indx).item_type = 9
            THEN
               same_out :=
                        tab1 (indx).mvc2 = tab2 (indx).mvc2;
            ELSIF tab1 (indx).item_type = 6
            THEN
               same_out :=
                        tab1 (indx).mnum = tab2 (indx).mnum;
            ELSIF tab1 (indx).item_type = 12
            THEN
               same_out :=
                          tab1 (indx).mdt = tab2 (indx).mdt;
            ELSIF tab1 (indx).item_type = 11
            THEN
               same_out :=
                        tab1 (indx).mrid = tab2 (indx).mrid;
            ELSIF tab1 (indx).item_type = 23
            THEN
               same_out :=
                        tab1 (indx).mraw = tab2 (indx).mraw;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               same_out := FALSE;
         END;

         EXIT WHEN NOT same_out;
         indx := tab1.NEXT (indx);
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         same_out := FALSE;
   END;

   PROCEDURE eqpipe (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      against_this_in IN VARCHAR2,
      check_nth_in IN VARCHAR2 := NULL,
      against_nth_in IN VARCHAR2 := NULL,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      check_tab msg_tbltype;
      against_tab msg_tbltype;
      check_status PLS_INTEGER;
      against_status PLS_INTEGER;
      same_message BOOLEAN := FALSE;
      v_check_nth PLS_INTEGER;
      v_against_nth PLS_INTEGER;
   BEGIN
      -- Compare contents of two pipes.
      LOOP
         receive_and_unpack (
            check_this_in,
            check_tab,
            check_status
         );
         receive_and_unpack (
            against_this_in,
            against_tab,
            against_status
         );

         IF     check_nth_in IS NULL
            AND against_nth_in IS NULL
         THEN
            -- No filtering on pipe messages

            IF (    check_status = 0
                AND against_status = 0)
            THEN
               compare_pipe_tabs (
                  check_tab,
                  against_tab,
                  same_message
               );
               EXIT WHEN NOT same_message;
            ELSIF (
                         check_status = 1
                     AND against_status = 1
                  )                              -- time out
            THEN
               same_message := TRUE;
               EXIT;
            ELSE
               same_message := FALSE;
               EXIT;
            END IF;
         ELSE
            utplsql.pl (
               'Checking Nth messages in pipes not currently supported.'
            );
            RAISE VALUE_ERROR;
         END IF;
      END LOOP;

      this (
         'Pipes equal? Compared "' || check_this_in ||
            '" against "' ||
            against_this_in ||
            '"',
         same_message,
         FALSE,
         raise_exc_in
      );
   END;

   FUNCTION numfromstr (str IN VARCHAR2)
      RETURN NUMBER
   IS
      sqlstr VARCHAR2(1000) := 
         'begin :val := ' || str || '; end;';
      &start73 
      fdbk PLS_INTEGER; 
      cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR; 
      &end73
      retval NUMBER;
   BEGIN
      &start81
      EXECUTE IMMEDIATE sqlstr USING  OUT retval;
      &end81
      &start73
      DBMS_SQL.PARSE (cur, sqlstr, DBMS_SQL.NATIVE);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.VARIABLE_VALUE (cur, 'val', retval);
      DBMS_SQL.CLOSE_CURSOR (cur);
      &end73
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.CLOSE_CURSOR (cur);
         &end73
         RAISE;
   END;
   
   PROCEDURE validatecoll (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,                          
      against_this_in IN VARCHAR2,                        
      countproc_in IN VARCHAR2 := 'COUNT',
      firstrowproc_in IN VARCHAR2 := 'FIRST',
      lastrowproc_in IN VARCHAR2 := 'LAST',
      check_startrow_in IN PLS_INTEGER := NULL,
      check_endrow_in IN PLS_INTEGER := NULL,
      against_startrow_in IN PLS_INTEGER := NULL,
      against_endrow_in IN PLS_INTEGER := NULL,
      match_rownum_in IN BOOLEAN := FALSE, 
      null_ok_in IN BOOLEAN := TRUE,
      raise_exc_in IN BOOLEAN := FALSE,
      null_and_valid IN OUT BOOLEAN
   )
   IS
      dynblock VARCHAR2 (32767);
      v_matchrow CHAR (1) := 'N';
      badc PLS_INTEGER;
      bada PLS_INTEGER;
      badtext VARCHAR2 (32767);
      eqcheck VARCHAR2 (32767);
   BEGIN
      null_and_valid := FALSE;
      
      IF numfromstr (check_this_in || '.' || countproc_in) = 0 AND 
         numfromstr (against_this_in || '.' || countproc_in) = 0
      THEN
         IF NOT null_ok_in
         THEN
            this (
               'Invalid NULL collections',
               FALSE,
               raise_exc_in => raise_exc_in);
         ELSE
            /* Empty and valid collections. We are done... */
            null_and_valid := TRUE;
         END IF;
      END IF;
      
      IF NOT null_and_valid
      THEN
         IF match_rownum_in
         THEN
            eq (
               'Different starting rows in ' ||
                  check_this_in || ' and ' || against_this_in,
               numfromstr (check_this_in || '.' || firstrowproc_in),
               numfromstr (against_this_in || '.' || firstrowproc_in),
               raise_exc_in => raise_exc_in
               );
               
            eq (
               'Different ending rows in ' ||
                  check_this_in || ' and ' || against_this_in,
               numfromstr (check_this_in || '.' || lastrowproc_in),
               numfromstr (against_this_in || '.' || lastrowproc_in),
               raise_exc_in => raise_exc_in
               );
         END IF;

         eq (
            'Different number of rows in ' ||
               check_this_in || ' and ' || against_this_in,
            numfromstr (check_this_in || '.' || countproc_in),
            numfromstr (against_this_in || '.' || countproc_in),
            raise_exc_in => raise_exc_in
            );
            
      END IF;
   END;
   
   FUNCTION dyncollstr (
      check_this_in IN VARCHAR2,                          
      against_this_in IN VARCHAR2,                        
      eqfunc_in IN VARCHAR2,
      countproc_in IN VARCHAR2,
      firstrowproc_in IN VARCHAR2,
      lastrowproc_in IN VARCHAR2,
      nextrowproc_in IN VARCHAR2,
      getvalfunc_in IN VARCHAR2
   )
   RETURN VARCHAR2
   IS
      eqcheck VARCHAR2 (32767);
      v_check VARCHAR2 (100) := check_this_in;
      v_against VARCHAR2 (100) := against_this_in;
   BEGIN
      IF getvalfunc_in IS NOT NULL
      THEN
         v_check := v_check || '.' || getvalfunc_in;
         v_against := v_against || '.' || getvalfunc_in;
      END IF;
      
      IF eqfunc_in IS NULL
      THEN
         eqcheck := 
            '('|| v_check || '(cindx) = ' ||
            v_against || ' (aindx)) OR ' ||
            '(' || v_check || '(cindx) IS NULL AND ' ||
            v_against || ' (aindx) IS NULL)';
      ELSE
         eqcheck :=
            eqfunc_in || '(' || 
            v_check || '(cindx), ' || 
            v_against || '(aindx))';
      END IF;

      RETURN (
         'DECLARE
             cindx PLS_INTEGER;
             aindx PLS_INTEGER;
             cend PLS_INTEGER := NVL (:cendit, ' || 
                check_this_in || '.' || lastrowproc_in || ');
             aend PLS_INTEGER := NVL (:aendit, ' || 
                against_this_in || '.' || lastrowproc_in || ');
             different_collections exception;

             PROCEDURE setfailure (
                str IN VARCHAR2,
                badc IN PLS_INTEGER, 
                bada IN PLS_INTEGER, 
                raiseexc IN BOOLEAN := TRUE)
             IS
             BEGIN
                :badcindx := badc;
                :badaindx := bada;
                :badreason := str;
                IF raiseexc THEN RAISE different_collections; END IF;
             END;
          BEGIN
             cindx := NVL (:cstartit, ' || 
                check_this_in || '.' || firstrowproc_in || ');
             aindx := NVL (:astartit, ' || 
                against_this_in || '.' || firstrowproc_in || ');

             LOOP
                IF cindx IS NULL AND aindx IS NULL 
                THEN
                   EXIT;
                   
                ELSIF cindx IS NULL and aindx IS NOT NULL
                THEN
                   setfailure (
                      ''Check index NULL, Against index NOT NULL'', cindx, aindx);
                   
                ELSIF aindx IS NULL
                THEN   
                   setfailure (
                      ''Check index NOT NULL, Against index NULL'', cindx, aindx);
                END IF;
                
                IF :matchit = ''Y''
                   AND cindx != aindx
                THEN
                   setfailure (''Mismatched row numbers'', cindx, aindx);
                END IF;

                BEGIN
                   IF ' || eqcheck || '
                   THEN
                      NULL;
                   ELSE
                      setfailure (''Mismatched row values'', cindx, aindx);
                   END IF;
                EXCEPTION
                   WHEN OTHERS
                   THEN
                      setfailure (''On EQ check: ' || eqcheck ||
                         ''' || '' '' || SQLERRM, cindx, aindx);
                END;
                
                cindx := ' || check_this_in || '.' || 
                   nextrowproc_in || '(cindx);
                aindx := ' || against_this_in || '.' || 
                   nextrowproc_in || '(aindx);
             END LOOP;
          EXCEPTION
             WHEN OTHERS THEN 
                IF :badcindx IS NULL and :badaindx IS NULL
                THEN setfailure (SQLERRM, cindx, aindx, FALSE);
                END IF;
          END;'
          );
   END;
   
   PROCEDURE eqcoll (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,                          
      against_this_in IN VARCHAR2,                        
      eqfunc_in IN VARCHAR2 := NULL,
      check_startrow_in IN PLS_INTEGER := NULL,
      check_endrow_in IN PLS_INTEGER := NULL,
      against_startrow_in IN PLS_INTEGER := NULL,
      against_endrow_in IN PLS_INTEGER := NULL,
      match_rownum_in IN BOOLEAN := FALSE,
      null_ok_in IN BOOLEAN := TRUE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
      dynblock VARCHAR2 (32767);
      v_matchrow CHAR (1) := 'N';
      badc PLS_INTEGER;
      bada PLS_INTEGER;
      badtext VARCHAR2 (32767);
      null_and_valid BOOLEAN := FALSE;
      &start73 
      fdbk PLS_INTEGER; 
      cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR; 
      &end73
   BEGIN
      validatecoll (
         msg_in,
         check_this_in,
         against_this_in,
         'COUNT',
         'FIRST',
         'LAST',
         check_startrow_in,
         check_endrow_in,
         against_startrow_in,
         against_endrow_in,
         match_rownum_in,
         null_ok_in,
         raise_exc_in,
         null_and_valid
      );
      
      IF null_and_valid THEN GOTO normal_termination; END IF;
      
      IF match_rownum_in THEN v_matchrow := 'Y'; END IF;
      
      dynblock :=
         dyncollstr (
            check_this_in,                        
            against_this_in,                      
            eqfunc_in,             
            'COUNT',                
            'FIRST',                
            'LAST',                 
            'NEXT',                 
            NULL                    
         );
      
            
      &start81
      EXECUTE IMMEDIATE dynblock
         USING 
            IN check_endrow_in,
            IN against_endrow_in,
            IN OUT badc,
            IN OUT bada,
            IN OUT badtext,
            IN check_startrow_in,
            IN against_startrow_in,
            IN v_matchrow;
      &end81
      &start73
      DBMS_SQL.PARSE (cur, dynblock, DBMS_SQL.NATIVE);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', check_endrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', against_endrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', check_startrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', against_startrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', v_matchrow);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badcindx', badc);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badaindx', bada);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badreason', badtext);
      DBMS_SQL.CLOSE_CURSOR (cur);
      &end73
      
     <<normal_termination>>
      
      this (
         msg_in || ' ' || badtext || ' for row ' ||
         NVL (TO_CHAR (badc), '*UNDEFINED*') || ' of "' || check_this_in ||
         '" and row ' || NVL (TO_CHAR (bada), '*UNDEFINED*') || ' of "' || 
         against_this_in || '"',     
         badc IS NULL AND bada IS NULL);
                                         
   EXCEPTION
      WHEN OTHERS
      THEN --p.l (sqlerrm);
         &start73
         DBMS_SQL.CLOSE_CURSOR (cur);
         &end73
         this (msg_in || ' Collection Equality Unknown Failure: ' || SQLERRM, FALSE);
   END;

   /* API based access to collections */
   PROCEDURE eqcollapi (
      msg_in IN VARCHAR2,
      check_this_pkg_in IN VARCHAR2, 
      against_this_pkg_in IN VARCHAR2, 
      eqfunc_in IN VARCHAR2 := NULL,
      countfunc_in IN VARCHAR2 := 'COUNT',
      firstrowfunc_in IN VARCHAR2 := 'FIRST',
      lastrowfunc_in IN VARCHAR2 := 'LAST',
      nextrowfunc_in IN VARCHAR2 := 'NEXT',
      getvalfunc_in IN VARCHAR2 := 'NTHVAL',
      check_startrow_in IN PLS_INTEGER := NULL,
      check_endrow_in IN PLS_INTEGER := NULL,
      against_startrow_in IN PLS_INTEGER := NULL,
      against_endrow_in IN PLS_INTEGER := NULL,
      match_rownum_in IN BOOLEAN := FALSE,
      null_ok_in IN BOOLEAN := TRUE,
      raise_exc_in IN BOOLEAN := FALSE
   ) 
   is 
      dynblock VARCHAR2 (32767);
      v_matchrow CHAR (1) := 'N';
      badc PLS_INTEGER;
      bada PLS_INTEGER;
      badtext VARCHAR2 (32767);
      null_and_valid BOOLEAN := FALSE;
      &start73 
      fdbk PLS_INTEGER; 
      cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR; 
      &end73
   BEGIN 
      validatecoll (
         msg_in,
         check_this_pkg_in,
         against_this_pkg_in,
         countfunc_in,
         firstrowfunc_in,
         lastrowfunc_in,
         check_startrow_in,
         check_endrow_in,
         against_startrow_in,
         against_endrow_in,
         match_rownum_in,
         null_ok_in,
         raise_exc_in,
         null_and_valid
      );
      
      IF null_and_valid THEN GOTO normal_termination; END IF;
      
      IF match_rownum_in THEN v_matchrow := 'Y'; END IF;
      
      dynblock :=
         dyncollstr (
            check_this_pkg_in,                     
            against_this_pkg_in,                   
            eqfunc_in,                
            countfunc_in,          
            firstrowfunc_in,          
            lastrowfunc_in,           
            nextrowfunc_in,           
            getvalfunc_in             
         );
      
      &start81
      EXECUTE IMMEDIATE dynblock
         USING 
            IN check_endrow_in,
            IN against_endrow_in,
            IN OUT badc,
            IN OUT bada,
            IN OUT badtext,
            IN check_startrow_in,
            IN against_startrow_in,
            IN v_matchrow;
      &end81
      &start73
      DBMS_SQL.PARSE (cur, dynblock, DBMS_SQL.NATIVE);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', check_endrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', against_endrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', check_startrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', against_startrow_in);
      DBMS_SQL.BIND_VARIABLE (cur, 'cendit', v_matchrow);
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badcindx', badc);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badaindx', bada);
      DBMS_SQL.VARIABLE_VALUE (cur, 'badreason', badtext);
      DBMS_SQL.CLOSE_CURSOR (cur);
      &end73
            
      <<normal_termination>>
      
      this (
         msg_in || ' ' || badtext || ' for row ' ||
         NVL (TO_CHAR (badc), '*UNDEFINED*') || ' of "' || check_this_pkg_in ||
         '" and row ' || NVL (TO_CHAR (bada), '*UNDEFINED*') || ' of "' || 
         against_this_pkg_in || '"',     
         badc IS NULL AND bada IS NULL);
                                         
   EXCEPTION
      WHEN OTHERS
      THEN --p.l (sqlerrm);
         &start73
         DBMS_SQL.CLOSE_CURSOR (cur);
         &end73
         this (msg_in || ' Collection Equality Unknown Failure: ' || SQLERRM, FALSE);
   END;
   
   PROCEDURE isnotnull (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         'IS NOT NULL: ' || msg_in,
         check_this_in IS NOT NULL,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      msg_in IN VARCHAR2,
      check_this_in IN VARCHAR2,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         'IS NULL: ' || msg_in,
         check_this_in IS NULL,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnotnull (
      msg_in IN VARCHAR2,
      check_this_in IN BOOLEAN,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         'IS NOT NULL: ' || msg_in,
         check_this_in IS NOT NULL,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      msg_in IN VARCHAR2,
      check_this_in IN BOOLEAN,
      null_ok_in IN BOOLEAN := FALSE,
      raise_exc_in IN BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         'IS NULL: ' || msg_in,
         check_this_in IS NULL,
         null_ok_in,
         raise_exc_in
      );
   END;

   --Check against a given exception block
   PROCEDURE ithrows (
      msg_in VARCHAR2,
      check_call_in VARCHAR2,
      exc_block_in VARCHAR2
   )
   IS
      v_block VARCHAR2(32767) := 
         'BEGIN ' || 
            check_call_in || ' 
            utAssert.this(msg_in => ''' || msg_in || '; No exception'',
                          check_this_in => FALSE, 
                          raise_exc_in => FALSE);
          EXCEPTION ' ||
            exc_block_in || '
          END;';
      &start73
      dyn_cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
      ret_val PLS_INTEGER;
      &end73
   BEGIN

      --Fire off the dynamic PL/SQL
      &start81
      EXECUTE IMMEDIATE v_block;
      &end81
      &start73
         DBMS_SQL.PARSE (dyn_cur, v_block, DBMS_SQL.NATIVE);

        ret_val := DBMS_SQL.EXECUTE (dyn_cur);
        DBMS_SQL.CLOSE_CURSOR (dyn_cur);
      &end73
   END;

   --Check a given call throws a named exception
   PROCEDURE throws (
      msg_in VARCHAR2,
      check_call_in IN VARCHAR2,
      against_exc_in IN VARCHAR2
   )
   IS
   BEGIN
      ithrows(msg_in,
         check_call_in,
         'WHEN ' || against_exc_in || ' THEN NULL;' ||
         'WHEN OTHERS THEN utAssert.this(msg_in => ''' || msg_in || 
            '; Wrong exception (got SQLCODE='' || SQLCODE || '')'',
                                         check_this_in => FALSE,
                                         raise_exc_in => FALSE);');
   END; 

   --Check a given call throws an exception with a given SQLCODE
   PROCEDURE throws (
      msg_in VARCHAR2,
      check_call_in IN VARCHAR2,
      against_exc_in IN NUMBER
   ) 
   IS
   BEGIN
      ithrows(msg_in,
         check_call_in,
         'WHEN OTHERS THEN utAssert.eq(msg_in => ''' || msg_in || '; Wrong exception '',
                                         check_this_in => SQLCODE,
                                         against_this_in => ' || against_exc_in || ',
                                         raise_exc_in => FALSE);');
   END; 

   /* Or have PLVexc-like standard handlers */

   PROCEDURE set_onerr_behavior (
      exception_in IN VARCHAR2,
      msg_in IN VARCHAR2,
      behavior_in IN VARCHAR2 := c_stop
   )
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE set_onerr_behavior (
      exception_in IN PLS_INTEGER,
      msg_in IN VARCHAR2,
      behavior_in IN VARCHAR2 := c_stop
   )
   IS
   BEGIN
      NULL;
   END;

   procedure showresults is begin g_showresults := true; end;
   procedure noshowresults is begin g_showresults := false; end;
   FUNCTION showing_results return boolean is begin return g_showresults; end;
   
END utassert;
/
REM SHO ERR
