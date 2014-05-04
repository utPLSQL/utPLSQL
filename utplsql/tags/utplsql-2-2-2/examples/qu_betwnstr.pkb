/* Formatted by PL/Formatter v3.1.2.1 on 2001/04/11 14:05 */

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
   PROCEDURE ut_betwnstr
   IS
      -- Verify and complete data types.
      against_this   VARCHAR2 (2000);
      check_this     VARCHAR2 (2000);
      datapack       utpack.datapack_t;
   BEGIN
      -- Define "control" operation for "normal"

      against_this := 'cde';
      -- Execute test code for "normal"

      check_this :=
         betwnstr (string_in=> 'abcdefgh',
            start_in    => 3,
            end_in      => 5
         );
      -- Assert success for "normal"

      -- Compare the two values.
      -- This is generated so record is used to avoid overloading issues.
      utassert2.eq (100, 'normal', check_this, against_this);
      -- End of test for "normal"

      -- Define "control" operation for "zero start"

      against_this := 'abc';
      -- Execute test code for "zero start"

      check_this :=
         betwnstr (string_in=> 'abcdefgh',
            start_in    => 0,
            end_in      => 2
         );
      -- Assert success for "zero start"

      -- Compare the two values.
      --utassert.eq ('zero start', check_this, against_this);
      utassert2.eq (101, 'zero start', check_this, against_this);
      -- End of test for "zero start"

      -- Define "control" operation for "null start"

      against_this := NULL;
      -- Execute test code for "null start"

      check_this :=
         betwnstr (string_in=> 'abcdefgh',
            start_in    => NULL,
            end_in      => 2
         );
      -- Assert success for "null start"

      -- Check for NULL return value.
      --utassert.isnull ('null start', against_this);
      utassert2.isnull (102, 'null start', against_this);
      -- End of test for "null start"

      -- Define "control" operation for "null end"

      against_this := NULL;
      -- Execute test code for "null end"

      check_this :=
         betwnstr (string_in=> 'abcdefgh',
            start_in    => 3,
            end_in      => NULL
         );
      -- Assert success for "null end"

      -- Check for NULL return value.
      --utassert.isnull ('null end', against_this);
      utassert2.isnull (103, 'null end', against_this);
   -- End of test for "null end"

      utassert2.eqtable (104, 'compare emps', 'emp', 'emp2');

   END ut_betwnstr;
END ut_betwnstr;
/


