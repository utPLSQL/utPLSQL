create or replace package test_reporters_1
as
  --%suite(A suite for testing html coverage options)
  
  --%test(a test calling package outside schema)
  procedure diffrentowner_test;

end;
/
