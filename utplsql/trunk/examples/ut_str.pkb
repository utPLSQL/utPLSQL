CREATE OR REPLACE PACKAGE BODY ut_str
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Ran setup');
   END;
   
   PROCEDURE ut_teardown
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Ran teardown');
   END;

   -- For each program to test...
   PROCEDURE ut_betwn IS
   BEGIN
      utAssert.eq (
         'Typical Valid Usage',
         str.betwn ('this is a string', 3, 7),
         'is is' 
         );
         
      utAssert.eq (
         'Null Start',
         str.betwn ('this is a string', NULL, 7),
         'ing'
         );
         
      utAssert.isNULL (
         'Start bigger than end',
         str.betwn ('this is a string', 3, 1)
         );
		 
	  utAssert.eval (
	     'Complex expression',
		 ':p1 = :p2 or :p1 like :p2',
		 'abc',
		 str.betwn ('abc%efg', 1,4)
		 );
   END ut_betwn;

   PROCEDURE ut_betwn2 IS
   BEGIN
      utAssert.eq (
         'Typical Valid Usage',
         str.betwn ('this is a string', -2, -6),
         'strin' 
         );

   END ut_betwn2;

END ut_str;
/
