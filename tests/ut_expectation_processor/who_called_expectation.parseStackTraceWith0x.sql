declare
  l_stack_trace varchar2(4000);
  l_source_line varchar2(4000);
begin
l_stack_trace := q'[----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
0x80e701d8        26  UT3.UT_EXPECTATION_RESULT
0x85e10150       112  UT3.UT_EXPECTATION
0x8b54bad8        21  UT3.UT_EXPECTATION_NUMBER
0x85cfd238        20  package body UT3.UT_EXAMPLETEST
0x85def380         6  anonymous block
0x85e93750      1825  package body SYS.DBMS_SQL
0x80f4f608       129  UT3.UT_EXECUTABLE
0x80f4f608        65  UT3.UT_EXECUTABLE
0x8a116010        76  UT3.UT_TEST
0x8a3348a0        48  UT3.UT_SUITE_ITEM
0x887e9948        67  UT3.UT_LOGICAL_SUITE
0x8a26de20        59  UT3.UT_RUN
0x8a3348a0        48  UT3.UT_SUITE_ITEM
0x838d17c0        28  anonymous block
]';
  l_source_line := ut_expectation_processor.WHO_CALLED_EXPECTATION(l_stack_trace);
  if l_source_line like 'at "UT3.UT_EXAMPLETEST", line 20 %' then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
