/* Formatted on 2001/07/13 12:29 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utsuiteutp 
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
Revision 1.5  2005/01/19 16:10:59  chrisrimmer
Removed AUTHID clauses from package bodies

Revision 1.4  2004/11/16 09:46:49  chrisrimmer
Changed to new version detection system.

Revision 1.3  2004/07/14 17:01:57  chrisrimmer
Added first version of pluggable reporter packages

Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

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
   &start_ge_8_1 PRAGMA AUTONOMOUS_TRANSACTION; &end_ge_8_1
   BEGIN
      utrerror.assert (suite_id_in IS NOT NULL, 'Suite ID cannot be null.');
      utrerror.assert (utp_id_in IS NOT NULL, 'UTP ID cannot be null.');

      INSERT INTO ut_suite_utp
                  (suite_id, utp_id, seq, enabled)
           VALUES (suite_id_in, utp_id_in, seq_in, enabled_in);
   &start_ge_8_1 COMMIT; &end_ge_8_1
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         -- already exists. Just ignore.
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
         NULL;
      WHEN OTHERS
      THEN
   IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
                     &start_ge_8_1 ROLLBACK; &end_ge_8_1
                     raise;
         ELSE
                  
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
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
      &start_ge_8_1 
      PRAGMA autonomous_transaction;
   &end_ge_8_1
   BEGIN
      DELETE FROM ut_suite_utp
            WHERE suite_id = suite_id_in
              AND utp_id = utp_id_in;
   &start_ge_8_1 COMMIT; &end_ge_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         utreport.pl (   'Remove suite-utp error: '
                     || SQLERRM);
         &start_ge_8_1 ROLLBACK; &end_ge_8_1
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
