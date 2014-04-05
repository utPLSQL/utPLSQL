create or replace package BODY ut_plvdate
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_to_date
   IS
      str VARCHAR2 (2000) := '1/1/1';
   BEGIN
      utassert.eq (
         'DD-MON-YYYY Conversion',
         STANDARD.TO_CHAR (PLVdate.to_date (str), 'DD-MON-YYYY'),
         '01-JAN-2001'
      );
   END;
   
   PROCEDURE ut_to_char
   IS
      dt DATE := SYSDATE;
   BEGIN
      utassert.eq (
         'MMDDYYYY conversion',
         PLVdate.to_char (SYSDATE, 'MMDDYYYY'),
         STANDARD.TO_CHAR (SYSDATE, 'MMDDYYYY')
      );
   END;
   
END ut_plvdate;
/
