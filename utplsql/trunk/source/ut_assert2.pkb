CREATE OR REPLACE PACKAGE BODY utassert2
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
Revision 1.2  2003/07/01 19:36:46  chrisrimmer
Added Standard Headers

************************************************************************/

   /* START chrisrimmer 42694 */
   g_previous_pass              BOOLEAN;
   /* END chrisrimmer 42694 */
   
   g_showresults                BOOLEAN     := FALSE ;
   c_not_placeholder   CONSTANT VARCHAR2 (10)
            := '#$NOT$#';

   -- DBMS_PIPE functionality based on code provided by John Beresniewicz, 
   -- Savant Corp, in ORACLE BUILT-IN PACKAGES

   -- For pipe equality checking
   TYPE msg_rectype IS RECORD (
      item_type                     INTEGER,
      mvc2                          VARCHAR2 (4093),
      mdt                           DATE,
      mnum                          NUMBER,
      mrid                          ROWID,
      mraw                          RAW (4093));

   /*
 || msg_tbltype tables can hold an ordered list of
 || message items, thus any message can be captured
 */
   TYPE msg_tbltype IS TABLE OF msg_rectype
      INDEX BY BINARY_INTEGER;

   FUNCTION id (name_in IN ut_assertion.NAME%TYPE)
      RETURN ut_assertion.id%TYPE
   IS
      retval   ut_assertion.id%TYPE;
   BEGIN
      SELECT id
        INTO retval
        FROM ut_assertion
       WHERE NAME = UPPER (name_in);

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION NAME (id_in IN ut_assertion.id%TYPE)
      RETURN ut_assertion.NAME%TYPE
   IS
      retval   ut_assertion.NAME%TYPE;
   BEGIN
      SELECT NAME
        INTO retval
        FROM ut_assertion
       WHERE id = id_in;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION replace_not_placeholder (
      stg_in       IN   VARCHAR2,
      success_in   IN   BOOLEAN
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF success_in
      THEN
         RETURN REPLACE (
                   stg_in,
                   c_not_placeholder,
                   NULL
                );
      ELSE
         RETURN REPLACE (
                   stg_in,
                   c_not_placeholder,
                   ' not '
                );
      END IF;
   END;

   PROCEDURE this (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE ,
      register_in     IN   BOOLEAN := TRUE
   )
   IS
      l_failure   BOOLEAN
   :=    NOT check_this_in
      OR (    check_this_in IS NULL
          AND NOT null_ok_in
         );
   BEGIN
      /* START chrisrimmer 42694 */
      g_previous_pass := NOT l_failure;

      /* END chrisrimmer 42694 */
      
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'utPLSQL TRACE on Assert: '
            || msg_in
         );
         utplsql.pl ('Results:');
         utplsql.bpl (l_failure);
      END IF;

      -- Report results failure and success

      utresult2.report (
         outcome_in,
         l_failure,
         utplsql.currcase.pkg || '.' || utplsql.currcase.name || ': ' || msg_in,
            /* 2.0.10.2 Idea from Alistair Bayley msg_in */
         register_in,
         showing_results
      );

      IF      raise_exc_in
          AND l_failure
      THEN
         RAISE test_failure;
      END IF;
   END;

   -- Support success and failure messages
   PROCEDURE this (
      outcome_in       IN   ut_outcome.id%TYPE,
      success_msg_in   IN   VARCHAR2,
      failure_msg_in   IN   VARCHAR2,
      check_this_in    IN   BOOLEAN,
      null_ok_in       IN   BOOLEAN := FALSE ,
      raise_exc_in     IN   BOOLEAN := FALSE ,
      register_in      IN   BOOLEAN := TRUE
   )
   IS
      l_failure   BOOLEAN
   :=    NOT check_this_in
      OR (    check_this_in IS NULL
          AND NOT null_ok_in
         );
   BEGIN
      IF l_failure
      THEN
         this (
            outcome_in,
            failure_msg_in,
            check_this_in,
            null_ok_in,
            raise_exc_in,
            register_in
         );
      ELSE
         this (
            outcome_in,
            success_msg_in,
            check_this_in,
            null_ok_in,
            raise_exc_in,
            register_in
         );
      END IF;
   END;

   FUNCTION expected (
      type_in    IN   VARCHAR2,
      msg_in     IN   VARCHAR2,
      value_in   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (   type_in
              || ' "'
              || msg_in
              || '" Result: "'
              || value_in
              || '"'
             );
   END;

   FUNCTION file_descrip (
      file_in   IN   VARCHAR2,
      dir_in    IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    file_in
             || '" located in "'
             || dir_in;
   END;

   FUNCTION message_expected (
      type_in           IN   VARCHAR2,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (   type_in
              || ' "'
              || msg_in
              || '" Expected "'
              || against_this_in
              || '" and got "'
              || check_this_in
              || '"'
             );
   END;

   FUNCTION message (
      type_in    IN   VARCHAR2,
      msg_in     IN   VARCHAR2,
      value_in   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN (   type_in
              || ' "'
              || msg_in
              || '" Result: '
              || value_in
             );
   END;

   -- Convert outcome name to ID.
   PROCEDURE get_id (
      outcome_in    IN       ut_outcome.NAME%TYPE,
      outcome_out   OUT      ut_outcome.id%TYPE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      l_id := utoutcome.id (outcome_in);

      IF l_id IS NULL
      THEN
         IF utplsql2.tracing
         THEN
            utplsql.pl (
                  'Outcome '
               || outcome_in
               || ' is not defined.'
            );
         END IF;

         utrerror.oc_report (
            run_in=> utplsql2.runnum,
            outcome_in=> NULL,
            errcode_in=> utrerror.undefined_outcome,
            errtext_in=>    'Outcome "'
                         || outcome_in
                         || '" is not defined.'
         );
      ELSE
         outcome_out := l_id;
      END IF;
   END;

   -- 2.0.8 General evaluation mechanism 
   PROCEDURE eval (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      using_in        IN   VARCHAR2, -- The expression   
      value_name_in   IN   value_name_tt,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      fdbk               PLS_INTEGER;
      cur                PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      eval_result        CHAR (1);
      eval_block         utplsql.maxvc2_t; -- Clear issues of size limitation!
      value_name_str     utplsql.maxvc2_t;
      eval_description   utplsql.maxvc2_t;
      parse_error        EXCEPTION;
   BEGIN
      IF utplsql2.tracing
      THEN
         -- Optional trace of assertion call.
         --utplsql.pl (<assertion-specific message>);
         NULL;
      END IF;

      FOR indx IN
          value_name_in.FIRST .. value_name_in.LAST
      LOOP
         value_name_str :=
               value_name_str
            || ' '
            || NVL (
                  value_name_in (indx).NAME,
                     'P'
                  || indx
               )
            || ' = '
            || value_name_in (indx).VALUE;
      END LOOP;

      eval_description :=    'Evaluation of "'
                          || using_in
                          || '" with'
                          || value_name_str;
      eval_block :=
            'DECLARE
           b_result BOOLEAN;
        BEGIN
           b_result := '
         || using_in
         || ';
           IF b_result THEN :result := '''
         || utplsql.c_yes
         || '''; '
         || 'ELSIF NOT b_result THEN :result := '''
         || utplsql.c_no
         || '''; '
         || 'ELSE :result := NULL;
           END IF;
        END;';

      BEGIN
         DBMS_SQL.parse (
            cur,
            eval_block,
            DBMS_SQL.native
         );
      EXCEPTION
         WHEN OTHERS
         THEN
            -- Report the parse error!
            IF DBMS_SQL.is_open (cur)
            THEN
               DBMS_SQL.close_cursor (cur);
            END IF;

            this (
               outcome_in=> outcome_in,
               success_msg_in=> NULL,
               failure_msg_in=>    'Error '
                                || SQLCODE
                                || ' parsing '
                                || eval_block,
               check_this_in=> FALSE ,
               null_ok_in=> null_ok_in,
               raise_exc_in=> raise_exc_in
            );
            RAISE parse_error;
      END;

      FOR indx IN
          value_name_in.FIRST .. value_name_in.LAST
      LOOP
         DBMS_SQL.bind_variable (
            cur,
            NVL (
               value_name_in (indx).NAME,
                  'P'
               || indx
            ),
            value_name_in (indx).VALUE
         );
      END LOOP;

      DBMS_SQL.bind_variable (cur, 'result', 'a');
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (
         cur,
         'result',
         eval_result
      );
      DBMS_SQL.close_cursor (cur);
      this (
         outcome_in=> outcome_in,
         success_msg_in=>    eval_description
                          || ' evaluated to TRUE',
         failure_msg_in=>    eval_description
                          || ' evaluated to FALSE',
         check_this_in=> utplsql.vc2bool (
                     eval_result
                  ),
         null_ok_in=> null_ok_in,
         raise_exc_in=> raise_exc_in
      );
   EXCEPTION
      WHEN parse_error
      THEN
         IF raise_exc_in
         THEN
            RAISE;
         ELSE
            NULL;
         END IF;
      WHEN OTHERS
      THEN
         IF DBMS_SQL.is_open (cur)
         THEN
            DBMS_SQL.close_cursor (cur);
         END IF;

         -- Likely the block got too large!
         this (
            outcome_in=> outcome_in,
            success_msg_in=> NULL,
            failure_msg_in=>    'Error in '
                             || eval_description
                             || ' SQLERRM: '
                             || SQLERRM,
            check_this_in=> FALSE ,
            null_ok_in=> null_ok_in,
            raise_exc_in=> raise_exc_in
         );
   END;

   PROCEDURE eval (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      using_in        IN   VARCHAR2, -- The expression   
      value_name_in   IN   value_name_tt,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eval (
         l_id,
         msg_in,
         using_in,
         value_name_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   /*
 Template Assertion program

 PROCEDURE <name> (
    outcome_in        IN   ut_outcome.id%TYPE,
    msg_in            IN   VARCHAR2,
    <assertion-specific arguments>
    null_ok_in        IN   BOOLEAN := FALSE,
    raise_exc_in      IN   BOOLEAN := FALSE
 )
 IS
 BEGIN
    IF utplsql2.tracing
    THEN
      -- Optional trace of assertion call.
       utplsql.pl (<assertion-specific message>);
    END IF;

    this (
       outcome_in => outcome_in,
       success_msg_in =>
        <Message you construct that is stored in the
       outcome table and also optionally displayed
       on the screen when the tests is a success>,
     failure_msg_in =>
        <Message you construct that is stored in the
       outcome table and also optionally displayed
       on the screen when the tests is a failure>,
       check_this_in =>
        <Boolean expression based on arguments that
        determine the TRUE-FALSE result of the assertion>,
       null_ok_in => FALSE,
       raise_exc_in => raise_exc_in
    );
 END;

 You might find the message_expected private program useful in
 constructing your message. Also the replace_not_placeholder and
 c_not_placeholder may come in handy if you want to use the this
 assertion program that accepts just a single message, as many
 of the original assertion programs do.

 */

   PROCEDURE eq (
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'EQ Compare "'
            || check_this_in
            || '" to "'
            || against_this_in
            || '"'
         );
      END IF;

      this (
         outcome_in=> outcome_in,
         msg_in=> message_expected (
                     'EQ',
                     msg_in,
                     check_this_in,
                     against_this_in
                  ),
         check_this_in=>    (NVL (
                                check_this_in =
                                   against_this_in,
                                FALSE
                             )
                            )
                         OR (    check_this_in IS NULL
                             AND against_this_in IS NULL
                             AND null_ok_in
                            ),
         null_ok_in=> FALSE ,
         raise_exc_in=> raise_exc_in
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
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   BOOLEAN,
      against_this_in   IN   BOOLEAN,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'Compare "'
            || b2v (check_this_in)
            || '" to "'
            || b2v (against_this_in)
            || '"'
         );
      END IF;

      this (
         outcome_in,
         message_expected (
            'EQ',
            msg_in,
            utplsql.bool2vc (check_this_in),
            utplsql.bool2vc (against_this_in)
         ),
            (check_this_in = against_this_in)
         OR (    check_this_in IS NULL
             AND against_this_in IS NULL
             AND null_ok_in
            ),
         FALSE ,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   DATE,
      against_this_in   IN   DATE,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE ,
      truncate_in       IN   BOOLEAN := FALSE
   )
   IS
      c_format   CONSTANT VARCHAR2 (30)
               := 'MONTH DD, YYYY HH24MISS';
      v_check             VARCHAR2 (100);
      v_against           VARCHAR2 (100);
   BEGIN
      IF truncate_in
      THEN
         v_check := TO_CHAR (
                       TRUNC (check_this_in),
                       c_format
                    );
         v_against :=
            TO_CHAR (
               TRUNC (against_this_in),
               c_format
            );
      ELSE
         v_check :=
                TO_CHAR (check_this_in, c_format);
         v_against :=
              TO_CHAR (against_this_in, c_format);
      END IF;

      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'Compare "'
            || v_check
            || '" to "'
            || v_against
            || '"'
         );
      END IF;

      this (
         outcome_in,
         message_expected (
            'EQ',
            msg_in,
            TO_CHAR (
               check_this_in,
               'MON-DD-YYYY HH:MI:SS'
            ),
            TO_CHAR (
               against_this_in,
               'MON-DD-YYYY HH:MI:SS'
            )
         ),
            (check_this_in = against_this_in)
         OR (    check_this_in IS NULL
             AND against_this_in IS NULL
             AND null_ok_in
            ),
         FALSE ,
         raise_exc_in
      );
   END;

   PROCEDURE ieqminus (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      query1_in       IN   VARCHAR2,
      query2_in       IN   VARCHAR2,
      minus_desc_in   IN   VARCHAR2,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      &start73
      fdbk      PLS_INTEGER;
      cur       PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      &end73
      ival      PLS_INTEGER;
      /* 2.0.8 suggested replacement below by Chris Rimmer
to avoid duplicate column name issues
:=    'DECLARE
 CURSOR cur IS ('
|| query1_in
|| ' MINUS '
|| query2_in
|| ')
UNION
('
|| query2_in
|| ' MINUS '
|| query1_in
|| '); */
      v_block   VARCHAR2 (32767)
   :=    'DECLARE
         CURSOR cur IS 
               SELECT 1
               FROM DUAL
               WHERE EXISTS (('
      || query1_in
      || ' MINUS '
      || query2_in
      || ')
        UNION
        ('
      || query2_in
      || ' MINUS '
      || query1_in
      || '));
          rec cur%ROWTYPE;
       BEGIN     
          OPEN cur;
          FETCH cur INTO rec;
          IF cur%FOUND 
		  THEN 
		     :retval := 1;
          ELSE 
		     :retval := 0;
          END IF;
          CLOSE cur;
       END;';
   BEGIN
      &start81
      EXECUTE IMMEDIATE v_block USING  OUT ival;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         v_block,
         DBMS_SQL.native
      );
      DBMS_SQL.bind_variable (
         cur,
         ':retval',
         ival
      );
      -- 1.5.6
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (
         cur,
         'retval',
         ival
      );
      DBMS_SQL.close_cursor (cur);
      &end73

      this (
         outcome_in,
         replace_not_placeholder (
            msg_in,
            ival = 0
         ),
         ival = 0,
         FALSE ,
         raise_exc_in
      );
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.close_cursor (cur);
         &end73


         this (
            outcome_in,
            replace_not_placeholder (
                  msg_in
               || ' SQL Failure: '
               || SQLERRM,
               SQLCODE = 0
            ),
            SQLCODE = 0,
            FALSE ,
            raise_exc_in
         );
   END;

   PROCEDURE eqtable (
      outcome_in         IN   ut_outcome.id%TYPE,
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      CURSOR info_cur (
         sch_in   IN   VARCHAR2,
         tab_in   IN   VARCHAR2
      )
      IS
         SELECT   t.column_name
             FROM all_tab_columns t
            WHERE t.owner = sch_in
              AND t.table_name = tab_in
         ORDER BY column_id;

      FUNCTION collist (tab IN VARCHAR2)
         RETURN VARCHAR2
      IS
         l_schema   VARCHAR2 (100);
         l_table    VARCHAR2 (100);
         l_dot      PLS_INTEGER
                               := INSTR (tab, '.');
         retval     VARCHAR2 (32767);
      BEGIN
         IF l_dot = 0
         THEN
            l_schema := USER;
            l_table := UPPER (tab);
         ELSE
            l_schema := UPPER (
                           SUBSTR (
                              tab,
                              1,
                                l_dot
                              - 1
                           )
                        );
            l_table :=
                UPPER (SUBSTR (tab,   l_dot
                                    + 1));
         END IF;

         FOR rec IN info_cur (l_schema, l_table)
         LOOP
            retval :=
                   retval
                || ','
                || rec.column_name;
         END LOOP;

         RETURN LTRIM (retval, ',');
      END;
   BEGIN
      ieqminus (
         outcome_in,
         message (
            'EQTABLE',
            msg_in,
               'Contents of "'
            || check_this_in
            || utplsql.ifelse (
                  check_where_in IS NULL,
                  '"',
                     '" WHERE '
                  || check_where_in
               )
            || ' does '
            || c_not_placeholder -- utplsql.ifelse (NOT l_failure, NULL, ' not ')
            || 'match "'
            || against_this_in
            || utplsql.ifelse (
                  against_where_in IS NULL,
                  '"',
                     '" WHERE '
                  || against_where_in
               )
         ),
            'SELECT T1.*, COUNT(*) FROM '
         || check_this_in
         || ' T1  WHERE '
         || NVL (check_where_in, '1=1')
         || ' GROUP BY '
         || collist (check_this_in),
            'SELECT T2.*, COUNT(*) FROM '
         || against_this_in
         || ' T2  WHERE '
         || NVL (against_where_in, '1=1')
         || ' GROUP BY '
         || collist (against_this_in),
         'Table Equality',
         raise_exc_in
      );
   END;

   PROCEDURE eqtabcount (
      outcome_in         IN   ut_outcome.id%TYPE,
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      ival   PLS_INTEGER;
   BEGIN
      ieqminus (
         outcome_in,
         message (
            'EQTABCOUNT',
            msg_in,
               'Row count of "'
            || check_this_in
            || utplsql.ifelse (
                  check_where_in IS NULL,
                  '"',
                     '" WHERE '
                  || check_where_in
               )
            || ' does '
            || c_not_placeholder -- utplsql.ifelse (NOT l_failure, NULL, ' not ')
            || 'match that of "'
            || against_this_in
            || utplsql.ifelse (
                  against_where_in IS NULL,
                  '"',
                     '" WHERE '
                  || against_where_in
               )
         ),
            'SELECT COUNT(*) FROM '
         || check_this_in
         || '  WHERE '
         || NVL (check_where_in, '1=1'),
            'SELECT COUNT(*) FROM '
         || against_this_in
         || '  WHERE '
         || NVL (against_where_in, '1=1'),
         'Table Count Equality',
         raise_exc_in
      );
   END;

   PROCEDURE eqquery (
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      -- User passes in two SELECT statements. Use NDS to minus them.
      ival   PLS_INTEGER;
   BEGIN
      ieqminus (
         outcome_in,
         message (
            'EQQUERY',
            msg_in,
               'Result set for "'
            || check_this_in
            || ' does '
            || c_not_placeholder -- utplsql.ifelse (NOT l_failure, NULL, ' not ')
            || 'match that of "'
            || against_this_in
            || '"'
         ),
         check_this_in,
         against_this_in,
         'Query Equality',
         raise_exc_in
      );
   END;

   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.id%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   VARCHAR2,
      null_ok_in         IN   BOOLEAN := FALSE ,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_value     VARCHAR2 (2000);
      l_success   BOOLEAN;

      &start81
      TYPE cv_t IS REF CURSOR;

      cv          cv_t;
      &end81
      &start73
      cur         PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      fdbk        PLS_INTEGER;
   &end73

   BEGIN
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'V EQQueryValue Compare "'
            || check_query_in
            || '" to "'
            || against_value_in
            || '"'
         );
      END IF;

      &start81
      OPEN cv FOR check_query_in;
      FETCH cv INTO l_value;
      CLOSE cv;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         check_query_in,
         DBMS_SQL.native
      );
      DBMS_SQL.define_column (cur, 1, 'a', 2000);
      fdbk := DBMS_SQL.execute_and_fetch (cur);
      DBMS_SQL.column_value (cur, 1, l_value);
      DBMS_SQL.close_cursor (cur);
      &end73
      l_success :=
            (l_value = against_value_in)
         OR (    l_value IS NULL
             AND against_value_in IS NULL
             AND null_ok_in
            );
      this (
         outcome_in,
         message (
            'EQQUERYVALUE',
            msg_in,
               'Query "'
            || check_query_in
            || '" returned value "'
            || l_value
            || '" that does '
            || utplsql.ifelse (
                  l_success,
                  NULL,
                  ' not '
               )
            || 'match "'
            || against_value_in
            || '"'
         ),
         l_success,
         FALSE ,
         raise_exc_in
      );
   /* For now ignore this condition.
    How do we handle two assertions inside a single assertion call?
             utAssert2.this (outcome_in, msg_in =>  ||
                msg_in ||
                ''' || ''; Got multiple values'',
                            check_this_in => FALSE,
                            raise_exc_in => ' ||
                b2v (raise_exc_in) ||
                ');
 */
   END;

   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.id%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   DATE,
      null_ok_in         IN   BOOLEAN := FALSE ,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_value     DATE;
      l_success   BOOLEAN;

      &start81
      TYPE cv_t IS REF CURSOR;

      cv          cv_t;
      &end81
      &start73
      cur         PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      fdbk        PLS_INTEGER;
   &end73

   BEGIN
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'D EQQueryValue Compare "'
            || check_query_in
            || '" to "'
            || against_value_in
            || '"'
         );
      END IF;

      &start81
      OPEN cv FOR check_query_in;
      FETCH cv INTO l_value;
      CLOSE cv;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         check_query_in,
         DBMS_SQL.native
      );
      DBMS_SQL.define_column (cur, 1, l_value);
      fdbk := DBMS_SQL.execute_and_fetch (cur);
      DBMS_SQL.column_value (cur, 1, l_value);
      DBMS_SQL.close_cursor (cur);
      &end73
      l_success :=
            (l_value = against_value_in)
         OR (    l_value IS NULL
             AND against_value_in IS NULL
             AND null_ok_in
            );
      this (
         outcome_in,
         message (
            'EQQUERYVALUE',
            msg_in,
               'Query "'
            || check_query_in
            || '" returned value "'
            || TO_CHAR (
                  l_value,
                  'DD-MON-YYYY HH24:MI:SS'
               )
            || '" that does '
            || utplsql.ifelse (
                  l_success,
                  NULL,
                  ' not '
               )
            || 'match "'
            || TO_CHAR (
                  against_value_in,
                  'DD-MON-YYYY HH24:MI:SS'
               )
            || '"'
         ),
         l_success,
         FALSE ,
         raise_exc_in,
         TRUE
      );
   /* For now ignore this condition.
    How do we handle two assertions inside a single assertion call?
             utAssert2.this (outcome_in, msg_in =>  ||
                msg_in ||
                ''' || ''; Got multiple values'',
                            check_this_in => FALSE,
                            raise_exc_in => ' ||
                b2v (raise_exc_in) ||
                ');
 */
   END;

   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.id%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   NUMBER,
      null_ok_in         IN   BOOLEAN := FALSE ,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_value     NUMBER;
      l_success   BOOLEAN;

      &start81

      TYPE cv_t IS REF CURSOR;

      cv          cv_t;
      &end81
      &start73
      cur         PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      fdbk        PLS_INTEGER;
   &end73

   BEGIN
      IF utplsql2.tracing
      THEN
         utplsql.pl (
               'N EQQueryValue Compare "'
            || check_query_in
            || '" to "'
            || against_value_in
            || '"'
         );
      END IF;

      &start81
      OPEN cv FOR check_query_in;
      FETCH cv INTO l_value;
      CLOSE cv;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         check_query_in,
         DBMS_SQL.native
      );
      DBMS_SQL.define_column (cur, 1, 1);
      fdbk := DBMS_SQL.execute_and_fetch (cur);
      DBMS_SQL.column_value (cur, 1, l_value);
      DBMS_SQL.close_cursor (cur);
      &end73

      l_success :=
            (l_value = against_value_in)
         OR (    l_value IS NULL
             AND against_value_in IS NULL
             AND null_ok_in
            );
      this (
         outcome_in,
         message (
            'EQQUERYVALUE',
            msg_in,
               'Query "'
            || check_query_in
            || '" returned value "'
            || l_value
            || '" that does '
            || utplsql.ifelse (
                  l_success,
                  NULL,
                  ' not '
               )
            || 'match "'
            || against_value_in
            || '"'
         ),
         l_success,
         FALSE ,
         raise_exc_in,
         TRUE
      );
   /* For now ignore this condition.
    How do we handle two assertions inside a single assertion call?
             utAssert2.this (outcome_in, msg_in =>  ||
                msg_in ||
                ''' || ''; Got multiple values'',
                            check_this_in => FALSE,
                            raise_exc_in => ' ||
                b2v (raise_exc_in) ||
                ');
 */
   END;

   PROCEDURE eqcursor (
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
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
      outcome_in            IN   ut_outcome.id%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      check_this_dir_in     IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      against_this_dir_in   IN   VARCHAR2 := NULL,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      checkid                  UTL_FILE.file_type;
      againstid                UTL_FILE.file_type;
      samefiles                BOOLEAN          := TRUE ;
      checkline                VARCHAR2 (32767);
      diffline                 VARCHAR2 (32767);
      againstline              VARCHAR2 (32767);
      check_eof                BOOLEAN;
      against_eof              BOOLEAN;
      diffline_set             BOOLEAN;
      nth_line                 PLS_INTEGER        := 1;
      cant_open_check_file     EXCEPTION;
      cant_open_against_file   EXCEPTION;

      PROCEDURE cleanup (
         val           IN   BOOLEAN,
         line_in       IN   VARCHAR2 := NULL,
         line_set_in   IN   BOOLEAN := FALSE ,
         linenum_in    IN   PLS_INTEGER := NULL,
         msg_in        IN   VARCHAR2
      )
      IS
      BEGIN
         UTL_FILE.fclose (checkid);
         UTL_FILE.fclose (againstid);
         this (
            outcome_in,
            message (
               'EQFILE',
               msg_in,
                  utplsql.ifelse (
                     line_set_in,
                        ' Line '
                     || linenum_in
                     || ' of ',
                     NULL
                  )
               || 'File "'
               || file_descrip (
                     check_this_in,
                     check_this_dir_in
                  )
               || '" does '
               || utplsql.ifelse (
                     val,
                     NULL,
                     ' not '
                  )
               || 'match "'
               || file_descrip (
                     against_this_in,
                     against_this_dir_in
                  )
               || '".'
            ),
            val,
            FALSE ,
            raise_exc_in,
            TRUE
         );
      END;
   BEGIN
      -- Compare contents of two files.
      BEGIN
         checkid :=
            UTL_FILE.fopen (
               check_this_dir_in,
               check_this_in,
               'R' &start81, max_linesize => 32767 &end81
            );
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE cant_open_check_file;
      END;

      BEGIN
         againstid :=
            UTL_FILE.fopen (
               NVL (
                  against_this_dir_in,
                  check_this_dir_in
               ),
               against_this_in,
               'R'
            &start81, max_linesize => 32767 &end81
            );
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE cant_open_against_file;
      END;

      LOOP
         BEGIN
            UTL_FILE.get_line (
               checkid,
               checkline
            );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               check_eof := TRUE ;
         END;

         BEGIN
            UTL_FILE.get_line (
               againstid,
               againstline
            );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               against_eof := TRUE ;
         END;

         IF (    check_eof
             AND against_eof
            )
         THEN
            samefiles := TRUE ;
            EXIT;
         ELSIF (checkline != againstline)
         THEN
            diffline := checkline;
            diffline_set := TRUE ;
            samefiles := FALSE ;
            EXIT;
         ELSIF (   check_eof
                OR against_eof
               )
         THEN
            samefiles := FALSE ;
            EXIT;
         END IF;

         IF samefiles
         THEN
            nth_line :=   nth_line
                        + 1;
         END IF;
      END LOOP;

      cleanup (
         samefiles,
         diffline,
         diffline_set,
         nth_line,
         msg_in
      );
   EXCEPTION
      WHEN cant_open_check_file
      THEN
         cleanup (
            FALSE ,
            msg_in=>    'Unable to open '
                     || file_descrip (
                           check_this_in,
                           check_this_dir_in
                        )
         );
      WHEN cant_open_against_file
      THEN
         cleanup (
            FALSE ,
            msg_in=>    'Unable to open '
                     || file_descrip (
                           against_this_in,
                           NVL (
                              against_this_dir_in,
                              check_this_dir_in
                           )
                        )
         );
      WHEN OTHERS
      THEN
         cleanup (FALSE , msg_in => msg_in);
   END;

   PROCEDURE receive_and_unpack (
      pipe_in           IN       VARCHAR2,
      msg_tbl_out       OUT      msg_tbltype,
      pipe_status_out   IN OUT   PLS_INTEGER
   )
   IS
      invalid_item_type   EXCEPTION;
      null_msg_tbl        msg_tbltype;
      next_item           INTEGER;
      item_count          INTEGER     := 0;
   BEGIN
      pipe_status_out :=
         DBMS_PIPE.receive_message (
            pipe_in,
            TIMEOUT=> 0
         );

      IF pipe_status_out != 0
      THEN
         RAISE invalid_item_type;
      END IF;

      LOOP
         next_item := DBMS_PIPE.next_item_type;
         EXIT WHEN next_item = 0;
         item_count :=   item_count
                       + 1;
         msg_tbl_out (item_count).item_type :=
                                        next_item;

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
      tab1                msg_tbltype,
      tab2                msg_tbltype,
      same_out   IN OUT   BOOLEAN
   )
   IS
      indx   PLS_INTEGER := tab1.FIRST;
   BEGIN
      LOOP
         EXIT WHEN indx IS NULL;

         BEGIN
            IF tab1 (indx).item_type = 9
            THEN
               same_out := tab1 (indx).mvc2 =
                                 tab2 (indx).mvc2;
            ELSIF tab1 (indx).item_type = 6
            THEN
               same_out := tab1 (indx).mnum =
                                 tab2 (indx).mnum;
            ELSIF tab1 (indx).item_type = 12
            THEN
               same_out := tab1 (indx).mdt =
                                  tab2 (indx).mdt;
            ELSIF tab1 (indx).item_type = 11
            THEN
               same_out := tab1 (indx).mrid =
                                 tab2 (indx).mrid;
            ELSIF tab1 (indx).item_type = 23
            THEN
               same_out := tab1 (indx).mraw =
                                 tab2 (indx).mraw;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               same_out := FALSE ;
         END;

         EXIT WHEN NOT same_out;
         indx := tab1.NEXT (indx);
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         same_out := FALSE ;
   END;

   PROCEDURE eqpipe (
      outcome_in        IN   ut_outcome.id%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      check_tab        msg_tbltype;
      against_tab      msg_tbltype;
      check_status     PLS_INTEGER;
      against_status   PLS_INTEGER;
      same_message     BOOLEAN     := FALSE ;
      msgset           BOOLEAN;
      msgnum           PLS_INTEGER;
      nthmsg           PLS_INTEGER := 1;
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

         IF (    check_status = 0
             AND against_status = 0
            )
         THEN
            compare_pipe_tabs (
               check_tab,
               against_tab,
               same_message
            );

            IF NOT same_message
            THEN
               msgset := TRUE ;
               msgnum := nthmsg;
               EXIT;
            END IF;

            EXIT WHEN NOT same_message;
         ELSIF (    check_status = 1
                AND against_status = 1
               ) -- time out
         THEN
            same_message := TRUE ;
            EXIT;
         ELSE
            same_message := FALSE ;
            EXIT;
         END IF;

         nthmsg :=   nthmsg
                   + 1;
      END LOOP;

      this (
         outcome_in,
         message (
            'EQPIPE',
            msg_in,
               utplsql.ifelse (
                  msgset,
                     ' Message '
                  || msgnum
                  || ' of ',
                  NULL
               )
            || 'Pipe "'
            || check_this_in
            || '" does '
            || utplsql.ifelse (
                  same_message,
                  NULL,
                  ' not '
               )
            || 'match "'
            || against_this_in
            || '".'
         ),
         same_message,
         FALSE ,
         raise_exc_in,
         TRUE
      );
   END;

   FUNCTION numfromstr (str IN VARCHAR2)
      RETURN NUMBER
   IS
      sqlstr   VARCHAR2 (1000)
            :=    'begin :val := '
               || str
               || '; end;';
      &start73 
      fdbk     PLS_INTEGER;
      cur      PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      &end73
      retval   NUMBER;
   BEGIN
      &start81
      EXECUTE IMMEDIATE sqlstr USING  OUT retval;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         sqlstr,
         DBMS_SQL.native
      );
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (cur, 'val', retval);
      DBMS_SQL.close_cursor (cur);
      &end73
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         &start73
         DBMS_SQL.close_cursor (cur);
         &end73
         RAISE;
   END;

   PROCEDURE validatecoll (
      msg_in                IN       VARCHAR2,
      check_this_in         IN       VARCHAR2,
      against_this_in       IN       VARCHAR2,
      valid_out             IN OUT   BOOLEAN,
      msg_out               OUT      VARCHAR2,
      countproc_in          IN       VARCHAR2
            := 'COUNT',
      firstrowproc_in       IN       VARCHAR2
            := 'FIRST',
      lastrowproc_in        IN       VARCHAR2
            := 'LAST',
      check_startrow_in     IN       PLS_INTEGER
            := NULL,
      check_endrow_in       IN       PLS_INTEGER
            := NULL,
      against_startrow_in   IN       PLS_INTEGER
            := NULL,
      against_endrow_in     IN       PLS_INTEGER
            := NULL,
      match_rownum_in       IN       BOOLEAN
            := FALSE ,
      null_ok_in            IN       BOOLEAN
            := TRUE ,
      raise_exc_in          IN       BOOLEAN
            := FALSE ,
      null_and_valid        IN OUT   BOOLEAN
   )
   IS
      dynblock     VARCHAR2 (32767);
      v_matchrow   CHAR (1)         := 'N';
      badc         PLS_INTEGER;
      bada         PLS_INTEGER;
      badtext      VARCHAR2 (32767);
      eqcheck      VARCHAR2 (32767);
   BEGIN
      valid_out := TRUE ;
      null_and_valid := FALSE ;

      IF      numfromstr (
                    check_this_in
                 || '.'
                 || countproc_in
              ) = 0
          AND numfromstr (
                    against_this_in
                 || '.'
                 || countproc_in
              ) = 0
      THEN
         IF NOT null_ok_in
         THEN
            valid_out := FALSE ;
            msg_out := 'Invalid NULL collections';
         ELSE
            /* Empty and valid collections. We are done... */
            null_and_valid := TRUE ;
         END IF;
      END IF;

      IF      valid_out
          AND NOT null_and_valid
      THEN
         IF match_rownum_in
         THEN
            valid_out :=
               NVL (
                  numfromstr (
                        check_this_in
                     || '.'
                     || firstrowproc_in
                  ) =
                     numfromstr (
                           against_this_in
                        || '.'
                        || firstrowproc_in
                     ),
                  FALSE
               );

            IF NOT valid_out
            THEN
               msg_out :=
                     'Different starting rows in '
                  || check_this_in
                  || ' and '
                  || against_this_in;
            ELSE
               valid_out :=
                  NVL (
                     numfromstr (
                           check_this_in
                        || '.'
                        || lastrowproc_in
                     ) !=
                        numfromstr (
                              against_this_in
                           || '.'
                           || lastrowproc_in
                        ),
                     FALSE
                  );

               IF NOT valid_out
               THEN
                  msg_out :=
                        'Different ending rows in '
                     || check_this_in
                     || ' and '
                     || against_this_in;
               END IF;
            END IF;
         END IF;

         IF valid_out
         THEN
            valid_out :=
               NVL (
                  numfromstr (
                        check_this_in
                     || '.'
                     || countproc_in
                  ) =
                     numfromstr (
                           against_this_in
                        || '.'
                        || countproc_in
                     ),
                  FALSE
               );

            IF NOT valid_out
            THEN
               msg_out :=
                     'Different number of rows in '
                  || check_this_in
                  || ' and '
                  || against_this_in;
            END IF;
         END IF;
      END IF;
   END;

   FUNCTION dyncollstr (
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      eqfunc_in         IN   VARCHAR2,
      countproc_in      IN   VARCHAR2,
      firstrowproc_in   IN   VARCHAR2,
      lastrowproc_in    IN   VARCHAR2,
      nextrowproc_in    IN   VARCHAR2,
      getvalfunc_in     IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      eqcheck     VARCHAR2 (32767);
      v_check     VARCHAR2 (100)   := check_this_in;
      v_against   VARCHAR2 (100)
                               := against_this_in;
   BEGIN
      IF getvalfunc_in IS NOT NULL
      THEN
         v_check :=
                    v_check
                 || '.'
                 || getvalfunc_in;
         v_against :=
                  v_against
               || '.'
               || getvalfunc_in;
      END IF;

      IF eqfunc_in IS NULL
      THEN
         eqcheck :=    '('
                    || v_check
                    || '(cindx) = '
                    || v_against
                    || ' (aindx)) OR '
                    || '('
                    || v_check
                    || '(cindx) IS NULL AND '
                    || v_against
                    || ' (aindx) IS NULL)';
      ELSE
         eqcheck :=    eqfunc_in
                    || '('
                    || v_check
                    || '(cindx), '
                    || v_against
                    || '(aindx))';
      END IF;

      RETURN (   'DECLARE
             cindx PLS_INTEGER;
             aindx PLS_INTEGER;
             cend PLS_INTEGER := NVL (:cendit, '
              || check_this_in
              || '.'
              || lastrowproc_in
              || ');
             aend PLS_INTEGER := NVL (:aendit, '
              || against_this_in
              || '.'
              || lastrowproc_in
              || ');
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
             cindx := NVL (:cstartit, '
              || check_this_in
              || '.'
              || firstrowproc_in
              || ');
             aindx := NVL (:astartit, '
              || against_this_in
              || '.'
              || firstrowproc_in
              || ');

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
                   IF '
              || eqcheck
              || '
                   THEN
                      NULL;
                   ELSE
                      setfailure (''Mismatched row values'', cindx, aindx);
                   END IF;
                EXCEPTION
                   WHEN OTHERS
                   THEN
                      setfailure (''On EQ check: '
              || eqcheck
              || ''' || '' '' || SQLERRM, cindx, aindx);
                END;
                
                cindx := '
              || check_this_in
              || '.'
              || nextrowproc_in
              || '(cindx);
                aindx := '
              || against_this_in
              || '.'
              || nextrowproc_in
              || '(aindx);
             END LOOP;
          EXCEPTION
             WHEN OTHERS THEN 
                IF :badcindx IS NULL and :badaindx IS NULL
                THEN setfailure (SQLERRM, cindx, aindx, FALSE);
                END IF;
          END;'
             );
   END;

   FUNCTION collection_message (
      collapi_in   IN   BOOLEAN,
      msg_in       IN   VARCHAR2,
      chkcoll_in   IN   VARCHAR2,
      chkrow_in    IN   INTEGER,
      agcoll_in    IN   VARCHAR2,
      agrow_in     IN   INTEGER,
      success_in   IN   BOOLEAN
   )
      RETURN VARCHAR2
   IS
      assert_name   VARCHAR2 (100) := 'EQCOLL';
   BEGIN
      IF collapi_in
      THEN
         assert_name := 'EQCOLLAPI';
      END IF;

      RETURN message (
                assert_name,
                msg_in,
                   utplsql.ifelse (
                      success_in,
                      NULL,
                         ' Row '
                      || NVL (
                            TO_CHAR (agrow_in),
                            '*UNDEFINED*'
                         )
                      || ' of '
                   )
                || 'Collection "'
                || agcoll_in
                || '" does '
                || utplsql.ifelse (
                      success_in,
                      NULL,
                      ' not '
                   )
                || 'match '
                || utplsql.ifelse (
                      success_in,
                      NULL,
                         ' Row '
                      || NVL (
                            TO_CHAR (chkrow_in),
                            '*UNDEFINED*'
                         )
                      || ' of '
                   )
                || chkcoll_in
                || '".'
             );
   END;

   PROCEDURE eqcoll (
      outcome_in            IN   ut_outcome.id%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      check_startrow_in     IN   PLS_INTEGER
            := NULL,
      check_endrow_in       IN   PLS_INTEGER
            := NULL,
      against_startrow_in   IN   PLS_INTEGER
            := NULL,
      against_endrow_in     IN   PLS_INTEGER
            := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE ,
      null_ok_in            IN   BOOLEAN := TRUE ,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      dynblock              VARCHAR2 (32767);
      v_matchrow            CHAR (1)         := 'N';
      valid_interim         BOOLEAN;
      invalid_interim_msg   VARCHAR2 (4000);
      badc                  PLS_INTEGER;
      bada                  PLS_INTEGER;
      badtext               VARCHAR2 (32767);
      null_and_valid        BOOLEAN          := FALSE ;
      &start73 
      fdbk                  PLS_INTEGER;
      cur                   PLS_INTEGER
                          := DBMS_SQL.open_cursor;
   &end73

   BEGIN
      validatecoll (
         msg_in,
         check_this_in,
         against_this_in,
         valid_interim,
         invalid_interim_msg,
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

      IF NOT valid_interim
      THEN
         -- Failure on interim step. Flag and skip rest of processing
         this (
            outcome_in,
            collection_message (
               FALSE ,
                  msg_in
               || ' - '
               || invalid_interim_msg,
               check_this_in,
               NULL,
               against_this_in,
               NULL,
               FALSE
            ),
            FALSE ,
            FALSE ,
            raise_exc_in,
            TRUE
         );
      ELSE
         -- We have some data to compare.
         IF NOT null_and_valid
         THEN
            IF match_rownum_in
            THEN
               v_matchrow := 'Y';
            END IF;

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
               USING  IN check_endrow_in,
                IN    against_endrow_in,
                IN  OUT badc,
                IN  OUT bada,
                IN  OUT badtext,
                IN    check_startrow_in,
                IN    against_startrow_in,
                IN    v_matchrow;
            &end81
            &start73
            DBMS_SQL.parse (
               cur,
               dynblock,
               DBMS_SQL.native
            );
            DBMS_SQL.bind_variable (
               cur,
               'cendit',
               check_endrow_in
            );
            DBMS_SQL.bind_variable (
               cur,
               'cendit',
               against_endrow_in
            );
            DBMS_SQL.bind_variable (
               cur,
               'cendit',
               check_startrow_in
            );
            DBMS_SQL.bind_variable (
               cur,
               'cendit',
               against_startrow_in
            );
            DBMS_SQL.bind_variable (
               cur,
               'cendit',
               v_matchrow
            );
            fdbk := DBMS_SQL.EXECUTE (cur);
            DBMS_SQL.variable_value (
               cur,
               'badcindx',
               badc
            );
            DBMS_SQL.variable_value (
               cur,
               'badaindx',
               bada
            );
            DBMS_SQL.variable_value (
               cur,
               'badreason',
               badtext
            );
            DBMS_SQL.close_cursor (cur);
         &end73
         END IF;

         this (
            outcome_in,
            collection_message (
               FALSE ,
               msg_in,
               check_this_in,
               badc,
               against_this_in,
               bada,
                   badc IS NULL
               AND bada IS NULL
            ),
                badc IS NULL
            AND bada IS NULL,
            FALSE ,
            raise_exc_in,
            TRUE
         );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN --p.l (sqlerrm);
         &start73
         DBMS_SQL.close_cursor (cur);
         &end73

         this (
            outcome_in,
            collection_message (
               FALSE ,
                  msg_in
               || ' SQLERROR: '
               || SQLERRM,
               check_this_in,
               badc,
               against_this_in,
               bada,
               SQLCODE = 0
            ),
            SQLCODE = 0,
            FALSE ,
            raise_exc_in,
            TRUE
         );
   END;

   /* API based access to collections */
   PROCEDURE eqcollapi (
      outcome_in            IN   ut_outcome.id%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_pkg_in     IN   VARCHAR2,
      against_this_pkg_in   IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      countfunc_in          IN   VARCHAR2 := 'COUNT',
      firstrowfunc_in       IN   VARCHAR2 := 'FIRST',
      lastrowfunc_in        IN   VARCHAR2 := 'LAST',
      nextrowfunc_in        IN   VARCHAR2 := 'NEXT',
      getvalfunc_in         IN   VARCHAR2
            := 'NTHVAL',
      check_startrow_in     IN   PLS_INTEGER
            := NULL,
      check_endrow_in       IN   PLS_INTEGER
            := NULL,
      against_startrow_in   IN   PLS_INTEGER
            := NULL,
      against_endrow_in     IN   PLS_INTEGER
            := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE ,
      null_ok_in            IN   BOOLEAN := TRUE ,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      dynblock              VARCHAR2 (32767);
      v_matchrow            CHAR (1)         := 'N';
      badc                  PLS_INTEGER;
      bada                  PLS_INTEGER;
      badtext               VARCHAR2 (32767);
      valid_interim         BOOLEAN;
      invalid_interim_msg   VARCHAR2 (4000);
      null_and_valid        BOOLEAN          := FALSE ;
      &start73 
      fdbk                  PLS_INTEGER;
      cur                   PLS_INTEGER
                          := DBMS_SQL.open_cursor;
   &end73

   BEGIN
      validatecoll (
         msg_in,
         check_this_pkg_in,
         against_this_pkg_in,
         valid_interim,
         invalid_interim_msg,
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

      IF null_and_valid
      THEN
         GOTO normal_termination;
      END IF;

      IF match_rownum_in
      THEN
         v_matchrow := 'Y';
      END IF;

      dynblock := dyncollstr (
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
         USING  IN check_endrow_in,
          IN    against_endrow_in,
          IN  OUT badc,
          IN  OUT bada,
          IN  OUT badtext,
          IN    check_startrow_in,
          IN    against_startrow_in,
          IN    v_matchrow;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         dynblock,
         DBMS_SQL.native
      );
      DBMS_SQL.bind_variable (
         cur,
         'cendit',
         check_endrow_in
      );
      DBMS_SQL.bind_variable (
         cur,
         'cendit',
         against_endrow_in
      );
      DBMS_SQL.bind_variable (
         cur,
         'cendit',
         check_startrow_in
      );
      DBMS_SQL.bind_variable (
         cur,
         'cendit',
         against_startrow_in
      );
      DBMS_SQL.bind_variable (
         cur,
         'cendit',
         v_matchrow
      );
      fdbk := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (
         cur,
         'badcindx',
         badc
      );
      DBMS_SQL.variable_value (
         cur,
         'badaindx',
         bada
      );
      DBMS_SQL.variable_value (
         cur,
         'badreason',
         badtext
      );
      DBMS_SQL.close_cursor (cur);

      &end73

      <<normal_termination>>
      this (
         outcome_in,
         collection_message (
            TRUE ,
            msg_in,
            check_this_pkg_in,
            badc,
            against_this_pkg_in,
            bada,
                badc IS NULL
            AND bada IS NULL
         ),
             bada IS NULL
         AND badc IS NULL,
         FALSE ,
         raise_exc_in,
         TRUE
      );
   EXCEPTION
      WHEN OTHERS
      THEN --p.l (sqlerrm);
         &start73
         DBMS_SQL.close_cursor (cur);
         &end73

         this (
            outcome_in,
            collection_message (
               TRUE ,
                  msg_in
               || ' SQLERROR: '
               || SQLERRM,
               check_this_pkg_in,
               badc,
               against_this_pkg_in,
               bada,
                   badc IS NULL
               AND bada IS NULL
            ),
            SQLCODE = 0,
            FALSE ,
            raise_exc_in,
            TRUE
         );
   END;

   PROCEDURE isnotnull (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         outcome_in,
         message_expected (
            'ISNOTNULL',
            msg_in,
            check_this_in,
            'NOT NULL'
         ),
         check_this_in IS NOT NULL,
         FALSE ,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         outcome_in,
         message_expected (
            'ISNULL',
            msg_in,
            check_this_in,
            ''
         ),
         check_this_in IS NULL,
         TRUE ,
         raise_exc_in
      );
   END;

   PROCEDURE isnotnull (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         outcome_in,
         message_expected (
            'ISNOTNULL',
            msg_in,
            utplsql.bool2vc (check_this_in),
            'NOT NULL'
         ),
         check_this_in IS NOT NULL,
         FALSE ,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      this (
         outcome_in,
         message_expected (
            'ISNULL',
            msg_in,
            utplsql.bool2vc (check_this_in),
            ''
         ),
         check_this_in IS NULL,
         TRUE ,
         raise_exc_in
      );
   END;

   --Check a given call throws a named exception
   PROCEDURE raises (
      outcome_in       IN   ut_outcome.id%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   VARCHAR2
   )
   IS
      expected_indicator   PLS_INTEGER      := 1000;
      l_indicator          PLS_INTEGER;
      v_block              VARCHAR2 (32767)
   :=    'BEGIN '
      || RTRIM (RTRIM (check_call_in), ';')
      || ';
               :indicator := 0;
             EXCEPTION
                WHEN '
      || against_exc_in
      || ' THEN
                   :indicator := '
      || expected_indicator
      || ';
                WHEN OTHERS THEN :indicator := SQLCODE;
             END;';
      &start73
      cur                  PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      ret_val              PLS_INTEGER;
   &end73
   BEGIN
      --Fire off the dynamic PL/SQL
      &start81
      EXECUTE IMMEDIATE v_block USING  OUT l_indicator;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         v_block,
         DBMS_SQL.native
      );
      DBMS_SQL.bind_variable (cur, 'indicator', 1);
      ret_val := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (
         cur,
         'indicator',
         l_indicator
      );
      DBMS_SQL.close_cursor (cur);
      &end73

      this (
         outcome_in,
         message (
            'RAISES',
            msg_in,
               'Block "'
            || check_call_in
            || '"'
            || utplsql.ifelse (
                  NOT (NVL (
                          l_indicator =
                               expected_indicator,
                          FALSE
                       )
                      ),
                  ' does not raise',
                  ' raises '
               )
            || ' Exception "'
            || against_exc_in
            || utplsql.ifelse (
                  l_indicator =
                               expected_indicator,
                  NULL,
                     '. Instead it raises SQLCODE = '
                  || l_indicator
                  || '.'
               )
         ),
         l_indicator = expected_indicator
      );
   END;

   --Check a given call throws an exception with a given SQLCODE
   PROCEDURE raises (
      outcome_in       IN   ut_outcome.id%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   NUMBER
   )
   IS
      expected_indicator   PLS_INTEGER      := 1000;
      l_indicator          PLS_INTEGER;
      v_block              VARCHAR2 (32767)
   :=    'BEGIN '
      || RTRIM (RTRIM (check_call_in), ';')
      || ';
               :indicator := 0;
             EXCEPTION
                WHEN OTHERS
                   THEN IF SQLCODE = '
      || against_exc_in
      || ' THEN :indicator := '
      || expected_indicator
      || ';'
      || ' ELSE :indicator := SQLCODE; END IF;
             END;';
      &start73
      cur                  PLS_INTEGER
                          := DBMS_SQL.open_cursor;
      ret_val              PLS_INTEGER;
   &end73
   BEGIN
      --Fire off the dynamic PL/SQL
      &start81
      EXECUTE IMMEDIATE v_block USING  OUT l_indicator;
      &end81
      &start73
      DBMS_SQL.parse (
         cur,
         v_block,
         DBMS_SQL.native
      );
      DBMS_SQL.bind_variable (cur, 'indicator', 1);
      ret_val := DBMS_SQL.EXECUTE (cur);
      DBMS_SQL.variable_value (
         cur,
         'indicator',
         l_indicator
      );
      DBMS_SQL.close_cursor (cur);
      &end73

      this (
         outcome_in,
         message (
            'THROWS',
            msg_in,
               'Block "'
            || check_call_in
            || '"'
            || utplsql.ifelse (
                  NOT (NVL (
                          l_indicator =
                               expected_indicator,
                          FALSE
                       )
                      ),
                  ' does not raise',
                  ' raises '
               )
            || ' Exception "'
            || against_exc_in
            || utplsql.ifelse (
                  l_indicator =
                               expected_indicator,
                  NULL,
                     '. Instead it raises SQLCODE = '
                  || l_indicator
                  || '.'
               )
         ),
         l_indicator = expected_indicator
      );
   END;

   PROCEDURE throws (
      outcome_in       IN   ut_outcome.id%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   VARCHAR2
   )
   IS
   BEGIN
      raises (
         outcome_in,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   PROCEDURE throws (
      outcome_in       IN   ut_outcome.id%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   NUMBER
   )
   IS
   BEGIN
      raises (
         outcome_in,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   -- Same assertions, but using NAME not ID to identify the test case.

   PROCEDURE this (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE ,
      register_in     IN   BOOLEAN := TRUE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      this (
         l_id,
         msg_in,
         check_this_in,
         null_ok_in,
         raise_exc_in,
         register_in
      );
   END;

   PROCEDURE eq (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eq (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   BOOLEAN,
      against_this_in   IN   BOOLEAN,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eq (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   DATE,
      against_this_in   IN   DATE,
      null_ok_in        IN   BOOLEAN := FALSE ,
      raise_exc_in      IN   BOOLEAN := FALSE ,
      truncate_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eq (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in,
         truncate_in
      );
   END;

   PROCEDURE eqtable (
      outcome_in         IN   ut_outcome.NAME%TYPE,
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqtable (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         check_where_in,
         against_where_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqtabcount (
      outcome_in         IN   ut_outcome.NAME%TYPE,
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqtabcount (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         check_where_in,
         against_where_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqquery (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqquery (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         raise_exc_in
      );
   END;

   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.NAME%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   VARCHAR2,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqqueryvalue (
         l_id,
         msg_in,
         check_query_in,
         against_value_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.NAME%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   DATE,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqqueryvalue (
         l_id,
         msg_in,
         check_query_in,
         against_value_in,
         raise_exc_in
      );
   END;

   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      outcome_in         IN   ut_outcome.NAME%TYPE,
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   NUMBER,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqqueryvalue (
         l_id,
         msg_in,
         check_query_in,
         against_value_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqcursor (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
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
      outcome_in            IN   ut_outcome.NAME%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      check_this_dir_in     IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      against_this_dir_in   IN   VARCHAR2 := NULL,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqfile (
         l_id,
         msg_in,
         check_this_in,
         check_this_dir_in,
         against_this_in,
         against_this_dir_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqpipe (
      outcome_in        IN   ut_outcome.NAME%TYPE,
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqpipe (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqcoll (
      outcome_in            IN   ut_outcome.NAME%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      check_startrow_in     IN   PLS_INTEGER
            := NULL,
      check_endrow_in       IN   PLS_INTEGER
            := NULL,
      against_startrow_in   IN   PLS_INTEGER
            := NULL,
      against_endrow_in     IN   PLS_INTEGER
            := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE ,
      null_ok_in            IN   BOOLEAN := TRUE ,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqcoll (
         l_id,
         msg_in,
         check_this_in,
         against_this_in,
         eqfunc_in,
         check_startrow_in,
         check_endrow_in,
         against_startrow_in,
         against_endrow_in,
         match_rownum_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   /* API based access to collections */
   PROCEDURE eqcollapi (
      outcome_in            IN   ut_outcome.NAME%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_pkg_in     IN   VARCHAR2,
      against_this_pkg_in   IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      countfunc_in          IN   VARCHAR2 := 'COUNT',
      firstrowfunc_in       IN   VARCHAR2 := 'FIRST',
      lastrowfunc_in        IN   VARCHAR2 := 'LAST',
      nextrowfunc_in        IN   VARCHAR2 := 'NEXT',
      getvalfunc_in         IN   VARCHAR2
            := 'NTHVAL',
      check_startrow_in     IN   PLS_INTEGER
            := NULL,
      check_endrow_in       IN   PLS_INTEGER
            := NULL,
      against_startrow_in   IN   PLS_INTEGER
            := NULL,
      against_endrow_in     IN   PLS_INTEGER
            := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE ,
      null_ok_in            IN   BOOLEAN := TRUE ,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqcollapi (
         l_id,
         msg_in,
         check_this_pkg_in,
         against_this_pkg_in,
         eqfunc_in,
         countfunc_in,
         firstrowfunc_in,
         lastrowfunc_in,
         nextrowfunc_in,
         getvalfunc_in,
         check_startrow_in,
         check_endrow_in,
         against_startrow_in,
         against_endrow_in,
         match_rownum_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnotnull (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      isnotnull (
         l_id,
         msg_in,
         check_this_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      isnull (
         l_id,
         msg_in,
         check_this_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnotnull (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      isnotnull (
         l_id,
         msg_in,
         check_this_in,
         raise_exc_in
      );
   END;

   PROCEDURE isnull (
      outcome_in      IN   ut_outcome.NAME%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      isnull (
         l_id,
         msg_in,
         check_this_in,
         raise_exc_in
      );
   END;

   --Check a given call throws a named exception
   PROCEDURE raises (
      outcome_in       IN   ut_outcome.NAME%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   VARCHAR2
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      raises (
         l_id,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   --Check a given call throws an exception with a given SQLCODE
   PROCEDURE raises (
      outcome_in       IN   ut_outcome.NAME%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   NUMBER
   )
   IS
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      raises (
         l_id,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   PROCEDURE throws (
      outcome_in       IN   ut_outcome.NAME%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   VARCHAR2
   )
   IS
   BEGIN
      raises (
         outcome_in,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   PROCEDURE throws (
      outcome_in       IN   ut_outcome.NAME%TYPE,
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   NUMBER
   )
   IS
   BEGIN
      raises (
         outcome_in,
         msg_in,
         check_call_in,
         against_exc_in
      );
   END;

   -- 2.0.7
   PROCEDURE fileexists (
      outcome_in     IN   ut_outcome.id%TYPE,
      msg_in         IN   VARCHAR2,
      dir_in         IN   VARCHAR2,
      file_in        IN   VARCHAR2,
      null_ok_in     IN   BOOLEAN := FALSE ,
      raise_exc_in   IN   BOOLEAN := FALSE
   )
   IS
      checkid   UTL_FILE.file_type;

      PROCEDURE cleanup (
         val      IN   BOOLEAN,
         msg_in   IN   VARCHAR2
      )
      IS
      BEGIN
         UTL_FILE.fclose (checkid);
         this (
            outcome_in,
            message (
               'FILEEXISTS',
               msg_in,
                  'File "'
               || file_descrip (file_in, dir_in)
               || '" could '
               || utplsql.ifelse (
                     val,
                     NULL,
                     ' not '
                  )
               || 'be opened for reading."'
            ),
            val,
            FALSE ,
            raise_exc_in,
            TRUE
         );
      END;
   BEGIN
      checkid :=
         UTL_FILE.fopen (
            dir_in,
            file_in,
            'R' &start81, max_linesize => 32767 &end81
         );
      cleanup (TRUE , msg_in);
   EXCEPTION
      WHEN OTHERS
      THEN
         cleanup (FALSE , msg_in);
   END;

   PROCEDURE showresults
   IS
   BEGIN
      g_showresults := TRUE ;
   END;

   PROCEDURE noshowresults
   IS
   BEGIN
      g_showresults := FALSE ;
   END;

   FUNCTION showing_results
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_showresults;
   END;

   /* START username:studious Date:01/11/2002 Task_id:42690
 Description: Checking whether object exists */

   FUNCTION find_obj (check_this_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
      v_st         VARCHAR2 (20);
      v_err        VARCHAR2 (100);
      v_schema     VARCHAR2 (100);
      v_obj_name   VARCHAR2 (100);
      v_point      NUMBER
                     := INSTR (check_this_in, '.');
      v_state      BOOLEAN        := FALSE ;
      v_val        VARCHAR2 (30);

      CURSOR c_obj
      IS
         SELECT object_name
           FROM all_objects
          WHERE object_name = UPPER (v_obj_name)
            AND owner = UPPER (v_schema);
   BEGIN
      IF v_point = 0
      THEN
         v_schema := USER;
         v_obj_name := check_this_in;
      ELSE
         v_schema := SUBSTR (
                        check_this_in,
                        0,
                        (  v_point
                         - 1
                        )
                     );
         v_obj_name := SUBSTR (
                          check_this_in,
                          (  v_point
                           + 1
                          )
                       );
      END IF;

      OPEN c_obj;
      FETCH c_obj INTO v_val;

      IF c_obj%FOUND
      THEN
         v_state := TRUE ;
      ELSE
         v_state := FALSE ;
      END IF;

      CLOSE c_obj;
      RETURN v_state;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE ;
   END;

   PROCEDURE objexists (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      IF utplsql2.tracing
      THEN
         -- Optional trace of assertion call.
         utplsql.pl (
               'verfying that the object "'
            || check_this_in
            || '"exists'
         );
      END IF;

      this (
         outcome_in,
         message (
            msg_in,
            check_this_in,
            'This object Exists'
         ),
         message (
            msg_in,
            check_this_in,
            'This object does not Exist'
         ),
         find_obj (check_this_in),
         null_ok_in,
         raise_exc_in,
         TRUE
      );
   END;

   PROCEDURE objnotexists (
      outcome_in      IN   ut_outcome.id%TYPE,
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      null_ok_in      IN   BOOLEAN := FALSE ,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
   BEGIN
      IF utplsql2.tracing
      THEN
         -- Optional trace of assertion call.
         utplsql.pl (
               'verifying that the object "'
            || check_this_in
            || '"does not exist'
         );
      END IF;

      this (
         outcome_in,
         message (
            msg_in,
            check_this_in,
            'This object does not Exist'
         ),
         message (
            msg_in,
            check_this_in,
            'This object Exists'
         ),
         NOT (find_obj (check_this_in)),
         null_ok_in,
         raise_exc_in,
         TRUE
      );
   END;
/* END username:studious Task_id:42690*/

   /* START chrisrimmer 42694 */
   FUNCTION previous_passed
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_previous_pass;
   END;

   FUNCTION previous_failed
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN NOT g_previous_pass;
   END;
/* END chrisrimmer 42694 */

   /* START chrisrimmer 42696 */
   PROCEDURE eqoutput (
      outcome_in            IN   ut_outcome.id%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   DBMS_OUTPUT.CHARARR,                     
      against_this_in       IN   DBMS_OUTPUT.CHARARR,
      ignore_case_in        IN   BOOLEAN := FALSE,
      ignore_whitespace_in  IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      v_check_index BINARY_INTEGER;
      v_against_index BINARY_INTEGER;
      v_message VARCHAR2(1000);
      v_line1 VARCHAR2(1000);      
      v_line2 VARCHAR2(1000);
      WHITESPACE CONSTANT CHAR(5) := '!' || CHR(9) || CHR(10) || CHR(13) || CHR(32) ;
      NOWHITESPACE CONSTANT CHAR(1) := '!';
      
      FUNCTION Preview_Line(line_in VARCHAR2) 
         RETURN VARCHAR2
      IS
      BEGIN
        IF LENGTH(line_in) <= 100 THEN
          RETURN line_in;
        ELSE
          RETURN SUBSTR(line_in, 1, 97) || '...';
        END IF;
      END;
      
   BEGIN
      v_check_index := check_this_in.FIRST;
      v_against_index := against_this_in.FIRST;
      
      WHILE v_check_index IS NOT NULL 
         AND v_against_index IS NOT NULL 
         AND v_message IS NULL 
      LOOP
      
         v_line1 := check_this_in(v_check_index);
         v_line2 := against_this_in(v_against_index);
         
         IF ignore_case_in THEN
           v_line1 := UPPER(v_line1);
           v_line2 := UPPER(v_line2);
         END IF;
      
         IF ignore_whitespace_in THEN
           v_line1 := TRANSLATE(v_line1, WHITESPACE, NOWHITESPACE);
           v_line2 := TRANSLATE(v_line2, WHITESPACE, NOWHITESPACE);
         END IF;
      
         IF (NVL (v_line1 <> v_line2, NOT null_ok_in)) THEN
           v_message := message_expected (
              'EQOUTPUT',
              msg_in,
              Preview_Line(check_this_in(v_check_index)),
              Preview_Line(against_this_in(v_against_index))) ||
                 ' (Comparing line ' || v_check_index || 
                 ' of tested collection against line ' || v_against_index ||
                 ' of reference collection)';
         END IF;
      
         v_check_index := check_this_in.NEXT(v_check_index);
         v_against_index := against_this_in.NEXT(v_against_index);
      END LOOP;
      
      IF v_message IS NULL THEN
         IF v_check_index IS NULL AND v_against_index IS NOT NULL THEN
            v_message := message (
               'EQOUTPUT',
                msg_in ,
                'Extra line found at end of reference collection: ' || 
                   Preview_Line(against_this_in(v_against_index)));
         ELSIF v_check_index IS NOT NULL AND v_against_index IS NULL THEN
            v_message := message (
               'EQOUTPUT',
                msg_in ,
                'Extra line found at end of tested collection: ' || 
                   Preview_Line(check_this_in(v_check_index)));
         END IF;
      END IF;
      
      this(outcome_in,
           NVL(v_message, message('EQOUTPUT', msg_in, 'Collections Match')), 
           v_message IS NULL, 
           FALSE, 
           raise_exc_in,
           TRUE);      
            
   END;

   PROCEDURE eqoutput (
      outcome_in            IN   ut_outcome.name%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   DBMS_OUTPUT.CHARARR,                     
      against_this_in       IN   DBMS_OUTPUT.CHARARR,
      ignore_case_in        IN   BOOLEAN := FALSE,
      ignore_whitespace_in  IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS 
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqoutput(
         l_id,
         msg_in,
         check_this_in,                     
         against_this_in,
         ignore_case_in,
         ignore_whitespace_in,
         null_ok_in,
         raise_exc_in
      );
   END;
   
   PROCEDURE eqoutput (
      outcome_in            IN   ut_outcome.id%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   DBMS_OUTPUT.CHARARR,                     
      against_this_in       IN   VARCHAR2,
      line_delimiter_in     IN   CHAR := NULL,
      ignore_case_in        IN   BOOLEAN := FALSE,
      ignore_whitespace_in  IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS 
      l_buffer DBMS_OUTPUT.CHARARR;
      l_against_this VARCHAR2(2000) := against_this_in;
      l_delimiter_pos BINARY_INTEGER; 
   BEGIN
   
      IF line_delimiter_in IS NULL THEN
        l_against_this := REPLACE(l_against_this, CHR(13) || CHR(10), CHR(10));
      END IF;
   
      WHILE l_against_this IS NOT NULL LOOP
        l_delimiter_pos := INSTR(l_against_this, NVL(line_delimiter_in, CHR(10)));
        IF l_delimiter_pos = 0 THEN
          l_buffer(l_buffer.COUNT) := l_against_this;
          l_against_this := NULL;
         ELSE
          l_buffer(l_buffer.COUNT) := SUBSTR(l_against_this, 1, l_delimiter_pos - 1);
          l_against_this := SUBSTR(l_against_this, l_delimiter_pos + 1);
          --Handle Case of delimiter at end
          IF l_against_this IS NULL THEN
             l_buffer(l_buffer.COUNT) := NULL;
          END IF;
        END IF;
      END LOOP;
   
      eqoutput(
         outcome_in,
         msg_in,
         check_this_in,                     
         l_buffer,
         ignore_case_in,
         ignore_whitespace_in,
         null_ok_in,
         raise_exc_in
      ); 
   END;

   PROCEDURE eqoutput (
      outcome_in            IN   ut_outcome.name%TYPE,
      msg_in                IN   VARCHAR2,
      check_this_in         IN   DBMS_OUTPUT.CHARARR,                     
      against_this_in       IN   VARCHAR2,
      line_delimiter_in     IN   CHAR := NULL,
      ignore_case_in        IN   BOOLEAN := FALSE,
      ignore_whitespace_in  IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS 
      l_id   ut_outcome.id%TYPE;
   BEGIN
      get_id (outcome_in, l_id);
      eqoutput(
         l_id,
         msg_in,
         check_this_in,                     
         against_this_in,
         line_delimiter_in,
         ignore_case_in,
         ignore_whitespace_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   /* END chrisrimmer 42696 */

   /* START VENKY11 12345 */

   PROCEDURE eq_refc_table(
      outcome_in        IN   ut_outcome.id%TYPE,
      p_msg_nm          IN   VARCHAR2,
      proc_name         IN   VARCHAR2,
      params            IN   utplsql_util.utplsql_params,
      cursor_position   IN   PLS_INTEGER,
      table_name        IN   VARCHAR2 )
   IS
      refc_table_name VARCHAR2(50);
   BEGIN
      refc_table_name := utplsql_util.prepare_and_fetch_rc(proc_name,params,cursor_position,1,table_name);
      IF (refc_table_name IS NOT NULL) THEN
         IF (utplsql.tracing) THEN
             dbms_output.put_line('Doing eqtable ');
         END IF;
         --utassert2.eqtable(outcome_in,p_msg_nm,'UTPLSQL.'||refc_table_name,table_name);
         utassert2.eqtable(outcome_in,p_msg_nm,refc_table_name,table_name);
      END IF;
      IF (utplsql.tracing) THEN
         dbms_output.put_line('Table dropped '||refc_table_name);
      END IF;
      utplsql_util.execute_ddl('DROP TABLE '||refc_table_name);
   END;

   PROCEDURE eq_refc_query(
      outcome_in        IN   ut_outcome.id%TYPE,
      p_msg_nm          IN   VARCHAR2,
      proc_name         IN   VARCHAR2,
      params            IN   utplsql_util.utplsql_params,
      cursor_position   IN   PLS_INTEGER,
      qry               IN   VARCHAR2 )
   IS
      refc_table_name VARCHAR2(50);
   BEGIN
      refc_table_name := utplsql_util.prepare_and_fetch_rc(proc_name,params,cursor_position,2,qry);
      IF (refc_table_name IS NOT NULL) THEN
         --utassert2.eqquery(outcome_in,p_msg_nm,'select * from '||'UTPLSQL.'||refc_table_name,qry);
         utassert2.eqquery(outcome_in,p_msg_nm,'select * from '||refc_table_name,qry);
      END IF;
      IF (utplsql.tracing) THEN
         dbms_output.put_line('Table dropped '||refc_table_name);
      END IF;
      utplsql_util.execute_ddl('DROP TABLE '||refc_table_name);
   END;

/* START VENKY11 12345 */



END utassert2;
/

