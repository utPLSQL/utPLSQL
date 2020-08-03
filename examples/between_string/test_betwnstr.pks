create or replace package test_betwnstr as

  -- %suite(Between string function)

  -- %test(Returns substring from start position to end position)
  procedure normal_case;

  -- %test(Returns substring when start position is zero)
  procedure zero_start_position;

  -- %test(Returns string until end if end position is greater than string length)
  procedure big_end_position;

  -- %test(Returns null for null input string value)
  procedure null_string;

  -- %test(Demo of a disabled test)
  -- %disabled
  procedure disabled_test;

end;
/
