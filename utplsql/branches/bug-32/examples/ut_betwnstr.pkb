CREATE OR REPLACE PACKAGE BODY ut_betwnstr
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
   
   PROCEDURE ut_BETWNSTR
   IS
      -- Verify and complete data types.
      against_this VARCHAR2(2000);
      check_this VARCHAR2(2000);
   BEGIN
      
      -- Define "control" operation for "normal"       
      against_this := 'cde';
       
      -- Execute test code for "normal"       
      check_this := 
      BETWNSTR (
         STRING_IN => 'abcdefgh'
         ,
         START_IN => 3
         ,
         END_IN => 5
       );
       
      -- Assert success for "normal" by comparing the two values.
      utAssert.eq (
         'normal',
         check_this,
         against_this
         );
      
      -- End of test for "normal"
      
      -- Define "control" operation for "zero start"
       
      against_this := 'abc';
       
      -- Execute test code for "zero start"
       
      check_this := 
      BETWNSTR (
         STRING_IN => 'abcdefgh'
         ,
         START_IN => 0
         ,
         END_IN => 2
       );
       
      -- Assert success for "zero start"
       
      -- Compare the two values.
      utAssert.eq (
         'zero start',
         check_this,
         against_this
         );
      
      -- End of test for "zero start"
      
      -- Define "control" operation for "null start"
       
      against_this := NULL;
       
      -- Execute test code for "null start"
       
      check_this := 
      BETWNSTR (
         STRING_IN => 'abcdefgh'
         ,
         START_IN => null
         ,
         END_IN => 2
       );
       
      -- Assert success for "null start"
       
      -- Check for NULL return value.
      utAssert.isNULL (
         'null start',
         check_this
         );
      
      -- End of test for "null start"
      
      -- Define "control" operation for "null end"
       
      against_this := NULL;
       
      -- Execute test code for "null end"
       
      check_this := 
      BETWNSTR (
         STRING_IN => 'abcdefgh'
         ,
         START_IN => 3
         ,
         END_IN => null
       );
       
      -- Assert success for "null end"
       
      -- Check for NULL return value.
      utAssert.isNULL (
         'null end',
         check_this
         );
      
      -- End of test for "null end"
   END ut_BETWNSTR;

END ut_betwnstr;
/
