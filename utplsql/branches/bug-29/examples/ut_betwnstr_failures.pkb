CREATE OR REPLACE PACKAGE BODY ut_betwnstr
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

   -- For each program to test...
   PROCEDURE ut_BETWNSTR IS
   BEGIN
      utAssert.eq (
         'Typical valid usage',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 3
            ,
            END_IN => 4
            ),
         'cde'
         );
         
      utAssert.isnull (
         'NULL start',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 1
            ,
            END_IN => 5
            )
         );


      utAssert.isnull (
         'NULL end',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 2
            ,
            END_IN => NULL
            )
         );
         
      utAssert.isnull (
         'End smaller than start',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 5
            ,
            END_IN => 5
            )
         );
         
      utAssert.eq (
         'End larger than string length',
         BETWNSTR(
            STRING_IN => 'abcdefg'
            ,
            START_IN => 3
            ,
            END_IN => 200
            ),
         'cdefg'
         );
         
   END ut_BETWNSTR;

END ut_betwnstr;
/
