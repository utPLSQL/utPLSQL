/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
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
/*Modification History:
studious:01/20/2002:Assertion for object existance
Venky:08-AUG-2002:Addes refcursor Assertions
*/

   g_showresults   BOOLEAN := FALSE;

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

   PROCEDURE this (
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      null_ok_in      IN   BOOLEAN := FALSE,
      raise_exc_in    IN   BOOLEAN := FALSE,
      register_in     IN   BOOLEAN := TRUE -- 2.0.1
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.this (
         l_outcome,
         msg_in,
         check_this_in,
         null_ok_in,
         raise_exc_in,
         register_in
      );
   END;

   PROCEDURE eval (
      msg_in            IN   VARCHAR2,
          using_in IN VARCHAR2, -- The expression
          value_name_in IN utAssert2.value_name_tt,
          null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eval (
         l_outcome,
         msg_in,
         using_in,
                 value_name_in,
         null_ok_in,
         raise_exc_in
      );
   END;
   
   PROCEDURE eval (
      msg_in            IN   VARCHAR2,
          using_in IN VARCHAR2, -- The expression
          value1_in IN VARCHAR2,
          value2_in IN VARCHAR2,
          name1_in IN VARCHAR2 := NULL,
          name2_in IN VARCHAR2 := NULL,   
          null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
          value_name utAssert2.value_name_tt;
   BEGIN
      value_name(1).value := value1_in;
      value_name(1).name := name1_in;
      value_name(2).value := value2_in;
      value_name(2).name := name2_in;
          
      utassert2.eval (
         l_outcome,
         msg_in,
         using_in,
                 value_name,
         null_ok_in,
         raise_exc_in
      );
   END;   
   
   PROCEDURE eq (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eq (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   BOOLEAN,
      against_this_in   IN   BOOLEAN,
      null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eq (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eq (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   DATE,
      against_this_in   IN   DATE,
      null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE,
      truncate_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eq (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         null_ok_in,
         raise_exc_in,
         truncate_in
      );
   END;

   PROCEDURE eqtable (
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqtable (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         check_where_in,
         against_where_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqtabcount (
      msg_in             IN   VARCHAR2,
      check_this_in      IN   VARCHAR2,
      against_this_in    IN   VARCHAR2,
      check_where_in     IN   VARCHAR2 := NULL,
      against_where_in   IN   VARCHAR2 := NULL,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqtabcount (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         check_where_in,
         against_where_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqquery (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqquery (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         raise_exc_in
      );
   END;

   --Check a query against a single VARCHAR2 value
   PROCEDURE eqqueryvalue (
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   VARCHAR2,
      null_ok_in         IN   BOOLEAN := FALSE,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqqueryvalue (
         l_outcome,
         msg_in,
         check_query_in,
         against_value_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   -- Check a query against a single DATE value
   PROCEDURE eqqueryvalue (
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   DATE,
      null_ok_in         IN   BOOLEAN := FALSE,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqqueryvalue (
         l_outcome,
         msg_in,
         check_query_in,
         against_value_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqqueryvalue (
      msg_in             IN   VARCHAR2,
      check_query_in     IN   VARCHAR2,
      against_value_in   IN   NUMBER,
      null_ok_in         IN   BOOLEAN := FALSE,
      raise_exc_in       IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqqueryvalue (
         l_outcome,
         msg_in,
         check_query_in,
         against_value_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqcursor (
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
      utplsql.pl ('utAssert.eqCursor is not yet implemented!');
   END;

   PROCEDURE eqfile (
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      check_this_dir_in     IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      against_this_dir_in   IN   VARCHAR2 := NULL,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqfile (
         l_outcome,
         msg_in,
         check_this_in,
         check_this_dir_in,
         against_this_in,
         against_this_dir_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqpipe (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      against_this_in   IN   VARCHAR2,
      check_nth_in      IN   VARCHAR2 := NULL,
      against_nth_in    IN   VARCHAR2 := NULL,
      raise_exc_in      IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqpipe (
         l_outcome,
         msg_in,
         check_this_in,
         against_this_in,
         raise_exc_in
      );
   END;

   PROCEDURE eqcoll (
      msg_in                IN   VARCHAR2,
      check_this_in         IN   VARCHAR2,
      against_this_in       IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      check_startrow_in     IN   PLS_INTEGER := NULL,
      check_endrow_in       IN   PLS_INTEGER := NULL,
      against_startrow_in   IN   PLS_INTEGER := NULL,
      against_endrow_in     IN   PLS_INTEGER := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqcoll (
         l_outcome,
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
      msg_in                IN   VARCHAR2,
      check_this_pkg_in     IN   VARCHAR2,
      against_this_pkg_in   IN   VARCHAR2,
      eqfunc_in             IN   VARCHAR2 := NULL,
      countfunc_in          IN   VARCHAR2 := 'COUNT',
      firstrowfunc_in       IN   VARCHAR2 := 'FIRST',
      lastrowfunc_in        IN   VARCHAR2 := 'LAST',
      nextrowfunc_in        IN   VARCHAR2 := 'NEXT',
      getvalfunc_in         IN   VARCHAR2 := 'NTHVAL',
      check_startrow_in     IN   PLS_INTEGER := NULL,
      check_endrow_in       IN   PLS_INTEGER := NULL,
      against_startrow_in   IN   PLS_INTEGER := NULL,
      against_endrow_in     IN   PLS_INTEGER := NULL,
      match_rownum_in       IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqcollapi (
         l_outcome,
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
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      null_ok_in      IN   BOOLEAN := FALSE,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.isnotnull (l_outcome, msg_in, check_this_in, raise_exc_in);
   END;

   PROCEDURE isnull (
      msg_in          IN   VARCHAR2,
      check_this_in   IN   VARCHAR2,
      null_ok_in      IN   BOOLEAN := FALSE,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.isnull (l_outcome, msg_in, check_this_in, raise_exc_in);
   END;

   PROCEDURE isnotnull (
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      null_ok_in      IN   BOOLEAN := FALSE,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.isnotnull (l_outcome, msg_in, check_this_in, raise_exc_in);
   END;

   PROCEDURE isnull (
      msg_in          IN   VARCHAR2,
      check_this_in   IN   BOOLEAN,
      null_ok_in      IN   BOOLEAN := FALSE,
      raise_exc_in    IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.isnull (l_outcome, msg_in, check_this_in, raise_exc_in);
   END;

   --Check a given call throws a named exception
   PROCEDURE throws (
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   VARCHAR2
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.throws (l_outcome, msg_in, check_call_in, against_exc_in);
   END;

   --Check a given call throws an exception with a given SQLCODE
   PROCEDURE throws (
      msg_in                VARCHAR2,
      check_call_in    IN   VARCHAR2,
      against_exc_in   IN   NUMBER
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.throws (l_outcome, msg_in, check_call_in, against_exc_in);
   END;

   PROCEDURE showresults
   IS
   BEGIN
      g_showresults := TRUE;
   END;

   PROCEDURE noshowresults
   IS
   BEGIN
      g_showresults := FALSE;
   END;

   FUNCTION showing_results
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_showresults;
   END;

/* START username:studious Date:01/11/2002 Task_id:42690
Description: Checking whether object exists */

   PROCEDURE objExists (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.objExists (
         l_outcome,
         msg_in,
         check_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;

   PROCEDURE objnotExists (
      msg_in            IN   VARCHAR2,
      check_this_in     IN   VARCHAR2,
      null_ok_in        IN   BOOLEAN := FALSE,
      raise_exc_in      IN   BOOLEAN := FALSE
   )IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.objnotExists (
         l_outcome,
         msg_in,
         check_this_in,
         null_ok_in,
         raise_exc_in
      );
   END;
/* END username:studious Task_id:42690*/

   /* START chrisrimmer 42694 */
   FUNCTION previous_passed
       RETURN BOOLEAN
   IS
   BEGIN
       RETURN utAssert2.previous_passed;
   END;

   FUNCTION previous_failed
       RETURN BOOLEAN
   IS
   BEGIN
       RETURN utAssert2.previous_failed;
   END;
   /* END chrisrimmer 42694 */
   
   /* START chrisrimmer 42696 */
   PROCEDURE eqoutput (
      msg_in                IN   VARCHAR2,
      check_this_in         IN   DBMS_OUTPUT.CHARARR,                     
      against_this_in       IN   DBMS_OUTPUT.CHARARR,
      ignore_case_in        IN   BOOLEAN := FALSE,
      ignore_whitespace_in  IN   BOOLEAN := FALSE,
      null_ok_in            IN   BOOLEAN := TRUE,
      raise_exc_in          IN   BOOLEAN := FALSE
   )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
      utassert2.eqoutput(
         l_outcome,
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
     l_outcome   ut_outcome.id%TYPE; 
   BEGIN
      utassert2.eqoutput(
         l_outcome,
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

   /* START VENKY11 45789 */

   PROCEDURE eq_refc_table(
      p_msg_nm          IN   VARCHAR2,
      proc_name         IN   VARCHAR2,
      params            IN   utplsql_util.utplsql_params,
      cursor_position   IN   PLS_INTEGER,
      table_name        IN   VARCHAR2 )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
     utassert2.eq_refc_table(l_outcome,p_msg_nm,proc_name,params,cursor_position,table_name);
   END;

   PROCEDURE eq_refc_query(
      p_msg_nm          IN   VARCHAR2,
      proc_name         IN   VARCHAR2,
      params            IN   utplsql_util.utplsql_params,
      cursor_position   IN   PLS_INTEGER,
      qry               IN   VARCHAR2 )
   IS
      l_outcome   ut_outcome.id%TYPE;
   BEGIN
     utassert2.eq_refc_query(l_outcome,p_msg_nm,proc_name,params,cursor_position,qry);
   END;

   /* END VENKY11 45789 */

END utassert;
/
REM SHO ERR
