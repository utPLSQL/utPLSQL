/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utsuiteutp -- &start81 AUTHID CURRENT_USER &end81
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

   -- Unit Test Framework for PL/SQL
   -- Steven Feuerstein, Copyright 2000, All rights reserved
   -- steven@stevenfeuerstein.com

   FUNCTION defined (
      suite_id_in   IN   ut_suite.id%TYPE,
      utp_id_in     IN   ut_utp.id%TYPE
   )
      RETURN BOOLEAN
   IS
      l_val   CHAR (1);
   BEGIN
      SELECT 'x'
        INTO l_val
        FROM ut_suite_utp
       WHERE suite_id = suite_id_in
         AND utp_id_in = utp_id;
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;

   FUNCTION seq (
      suite_id_in   IN   ut_suite.id%TYPE,
      utp_id_in     IN   ut_utp.id%TYPE
   )
      RETURN ut_suite_utp.seq%TYPE
   IS
      retval   ut_suite_utp.seq%TYPE;
   BEGIN
      SELECT seq
        INTO retval
        FROM ut_suite_utp
       WHERE suite_id = suite_id_in
         AND utp_id_in = utp_id;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION enabled (
      suite_id_in   IN   ut_suite.id%TYPE,
      utp_id_in     IN   ut_utp.id%TYPE
   )
      RETURN ut_suite_utp.enabled%TYPE
   IS
      l_val   ut_suite_utp.enabled%TYPE;
   BEGIN
      SELECT enabled
        INTO l_val
        FROM ut_suite_utp
       WHERE suite_id = suite_id_in
         AND utp_id_in = utp_id;
      RETURN l_val;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;
   
   PROCEDURE ADD (
      suite_id_in   IN   ut_suite.id%TYPE,
      utp_id_in     IN   ut_utp.id%TYPE,
      seq_in        IN   ut_suite_utp.seq%TYPE := NULL
     ,enabled_in    IN   ut_suite_utp.enabled%TYPE := NULL
   )
   IS
   &start81 PRAGMA AUTONOMOUS_TRANSACTION; &end81
   BEGIN
      utrerror.assert (suite_id_in IS NOT NULL, 'Suite ID cannot be null.');
      utrerror.assert (utp_id_in IS NOT NULL, 'UTP ID cannot be null.');

      INSERT INTO ut_suite_utp
                  (suite_id, utp_id, seq, enabled)
           VALUES (suite_id_in, utp_id_in, seq_in, enabled_in);
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- already exists. Just ignore.
         &start81 ROLLBACK; &end81
         NULL;
      WHEN OTHERS
      THEN
   IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
                     &start81 ROLLBACK; &end81
                     raise;
         ELSE
                  
         &start81 ROLLBACK; &end81
         utrerror.report_define_error (
            c_abbrev,
               'Suite '
            || suite_id_in
            || ' UTP '
            || utp_id_in
         );
         end if;
   END;

   PROCEDURE rem (
      suite_id_in   IN   ut_suite.id%TYPE,
      utp_id_in     IN   ut_utp.id%TYPE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;
   &end81
   BEGIN
      DELETE FROM ut_suite_utp
            WHERE suite_id = suite_id_in
              AND utp_id = utp_id_in;
   &start81 COMMIT; &end81
   EXCEPTION
      WHEN OTHERS
      THEN
         utplsql.pl (   'Remove suite-utp error: '
                     || SQLERRM);
         &start81 ROLLBACK; &end81
         RAISE;
   END;

	  
   FUNCTION utps (
      suite_in in ut_suite.id%TYPE
   )
      RETURN utconfig.refcur_t
   IS
      retval   utconfig.refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT u.program, u.name, u.id utp_id, su.enabled
           FROM ut_utp u, ut_suite_utp su
          WHERE su.suite_id = suite_in
		  and su.utp_id = u.id;
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN retval;
   END;	
	  
   FUNCTION utps (
      suite_in in ut_suite.name%TYPE
   )
      RETURN utconfig.refcur_t
   IS
      retval   utconfig.refcur_t;
   BEGIN
      return utps (utsuite.id_from_name (suite_in));
   END;	  
END utsuiteutp;
/
