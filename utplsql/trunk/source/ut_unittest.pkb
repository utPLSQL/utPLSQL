/* Formatted on 2001/07/14 08:45 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY utunittest
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
Revision 1.2  2003/07/01 19:36:47  chrisrimmer
Added Standard Headers

************************************************************************/

   FUNCTION name (
      ut_in    IN   ut_unittest%ROWTYPE
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN  c_abbrev || utconfig.delimiter || ut_in.id;
   END name;

  FUNCTION name (
      id_in IN ut_unittest.id%TYPE
   )
      RETURN VARCHAR2 is rec ut_unittest%rowtype;
      begin
      rec := onerow (id_in);
      return name (rec); end;
      
            
FUNCTION full_name (
      utp_in   IN   ut_utp%ROWTYPE,
      ut_in    IN   ut_unittest%ROWTYPE
   )
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    ututp.qualified_name (utp_in) || '.'
             || name (ut_in.id);
   END full_name;   

   FUNCTION onerow (id_in IN ut_unittest.id%TYPE)
      RETURN ut_unittest%ROWTYPE
   IS
      retval   ut_unittest%ROWTYPE;
      empty_rec   ut_unittest%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM ut_unittest
       WHERE id = id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   FUNCTION program_name (id_in IN ut_unittest.id%TYPE)
      RETURN ut_unittest.program_name%TYPE
   IS
      retval   ut_unittest.program_name%TYPE;
   BEGIN
      SELECT program_name
        INTO retval
        FROM ut_unittest
       WHERE id = id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION id (name_in IN VARCHAR2)
      RETURN ut_unittest.id%TYPE
   IS
      l_delimiter   ut_config.delimiter%TYPE   := utconfig.delimiter;
      l_loc         PLS_INTEGER;
      retval        ut_unittest.id%TYPE;
   BEGIN
      l_loc := INSTR (name_in, l_delimiter);

      IF l_loc = 0
      THEN
         RETURN NULL;
      ELSE
         RETURN to_number (SUBSTR (name_in,   l_loc
                                  + LENGTH (l_delimiter))
                );
      END IF;
      end;

   PROCEDURE ADD (
      utp_id_in        IN   ut_unittest.utp_id%TYPE, 
      program_name_in          IN   ut_unittest.program_name%TYPE,
      seq_in           IN   ut_unittest.seq%TYPE := NULL,
      description_in   IN   ut_unittest.description%TYPE
            := NULL
   )
   IS
      &start_ge_8_1 
      PRAGMA autonomous_transaction;
      &start_ge_8_1
      l_id   ut_unittest.id%TYPE;
   BEGIN
      SELECT ut_unittest_seq.NEXTVAL
        INTO l_id
        FROM DUAL;

      INSERT INTO ut_unittest
                  (id, program_name, seq,
                   description)
           VALUES (l_id, UPPER (program_name_in), seq_in,  description_in);

      &start_ge_8_1 
      COMMIT;
   &start_ge_8_1
   EXCEPTION
      WHEN OTHERS
      THEN
         IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
            &start_ge_8_1 ROLLBACK; &start_ge_8_1
            RAISE;
         ELSE
            &start_ge_8_1 ROLLBACK; &start_ge_8_1
            utrerror.report_define_error (
               c_abbrev,
                  'Unittest for '
               || program_name_in
               || ' UTP ID '
               || utp_id_in
            );
         END IF;
   END;

   PROCEDURE rem (
      name_in       IN   varchar2
   )
   IS begin rem (id (name_in));
   END;

   PROCEDURE rem (id_in IN ut_unittest.id%TYPE)
   IS
      &start_ge_8_1 
      PRAGMA autonomous_transaction;
   &start_ge_8_1
   BEGIN
      DELETE FROM ut_unittest
            WHERE id = id_in;

      &start_ge_8_1 
      COMMIT;
   &start_ge_8_1 
   EXCEPTION
      WHEN OTHERS
      THEN
         IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
            &start_ge_8_1 ROLLBACK; &start_ge_8_1
            RAISE;
         ELSE
            &start_ge_8_1 ROLLBACK; &start_ge_8_1
            utrerror.report_define_error (
               c_abbrev,
                  'Unittest ID '
               || id_in
            );
         END IF;
   END;
END utunittest;
/

