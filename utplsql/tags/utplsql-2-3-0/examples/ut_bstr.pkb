CREATE OR REPLACE PACKAGE BODY ut_bstr
IS
   PROCEDURE ut_setup
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Ran bstr setup');
   END;
   
   PROCEDURE ut_teardown
   IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE ('Ran bstr teardown');
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
      
   END ut_BETWNSTR;

END ut_bstr;
/
