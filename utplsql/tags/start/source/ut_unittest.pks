/* Formatted on 2001/07/13 17:50 (RevealNet Formatter v4.4.0) */
CREATE OR REPLACE PACKAGE utunittest
IS
   c_name     CONSTANT CHAR (9) := 'UNIT TEST';
   c_abbrev   CONSTANT CHAR (2) := 'UT';

   /* UT##NNN */
   FUNCTION name (
      ut_in    IN   ut_unittest%ROWTYPE
   )
      RETURN VARCHAR2;
      
   /* SCHEMA.UTP##NNN.UT##NNN */
   FUNCTION full_name (
      utp_in   IN   ut_utp%ROWTYPE,
      ut_in    IN   ut_unittest%ROWTYPE
   )
      RETURN VARCHAR2;      
      
  FUNCTION name (
      id_in IN ut_unittest.id%TYPE
   )
      RETURN VARCHAR2;

   FUNCTION onerow (id_in IN ut_unittest.id%TYPE)
      RETURN ut_unittest%ROWTYPE;

   FUNCTION program_name (id_in IN ut_unittest.id%TYPE)
      RETURN ut_unittest.program_name%TYPE;

   FUNCTION id (name_in IN VARCHAR2)
      RETURN ut_unittest.id%TYPE;

   PROCEDURE ADD (
      utp_id_in        IN   ut_unittest.utp_id%TYPE,      
      program_name_in          IN   ut_unittest.program_name%TYPE,
      seq_in           IN   ut_unittest.seq%TYPE := NULL,
      description_in   IN   ut_unittest.description%TYPE
            := NULL
   );

   PROCEDURE rem (
      name_in     IN   VARCHAR2
   );

   PROCEDURE rem (id_in IN ut_unittest.id%TYPE);
END;
/

