create or replace package body test_expectation_processor is

  gc_user constant varchar2(128) := sys_context('userenv','current_schema');

  procedure who_called_expectation is
    l_stack_trace varchar2(4000);
    l_source_line varchar2(4000);
  begin
    l_stack_trace := q'[----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
34f88e4420       124  package body SCH_TEST.UT_EXPECTATION_PROCESSOR
353dfeb2f8        26  SCH_TEST.UT_EXPECTATION_RESULT
cba2493ce0       112  SCH_TEST.UT_EXPECTATION
3539881cf0        21  SCH_TEST.UT_EXPECTATION_NUMBER
351a608008         7  package body ]'||gc_user||q'[.TEST_EXPECTATION_PROCESSOR
351a608018        12  package body ]'||gc_user||q'[.TEST_EXPECTATION_PROCESSOR
351a608018        24  package body ]'||gc_user||q'[.TEST_EXPECTATION_PROCESSOR
351a6862b8         6  anonymous block
351fe31010      1825  package body SYS.DBMS_SQL
20befbe4d8       129  SCH_TEST.UT_EXECUTABLE
20befbe4d8        65  SCH_TEST.UT_EXECUTABLE
34f8ab7cd8        80  SCH_TEST.UT_TEST
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
34f8ab9b10        74  SCH_TEST.UT_SUITE
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
cba24bfad0        75  SCH_TEST.UT_LOGICAL_SUITE
353dfecf30        59  SCH_TEST.UT_RUN
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
357f5421e8        77  package body SCH_TEST.UT_RUNNER
357f5421e8       111  package body SCH_TEST.UT_RUNNER
20be951ab0       292  package body SCH_TEST.UT
20be951ab0       320  package body SCH_TEST.UT
]';
    ut.expect(
        ut3.ut_expectation_processor.who_called_expectation(l_stack_trace)
    ).to_equal('at "'||gc_user||'.TEST_EXPECTATION_PROCESSOR", line 7 l_source_line varchar2(4000);
at "'||gc_user||'.TEST_EXPECTATION_PROCESSOR", line 12
at "'||gc_user||'.TEST_EXPECTATION_PROCESSOR", line 24');
  end;


  procedure who_called_expectation_0x is
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
    ut.expect(
        ut3.ut_expectation_processor.who_called_expectation(l_stack_trace)
    ).to_be_like('at "UT3.UT_EXAMPLETEST", line 20 %');
  end;

  procedure who_call_expectation_win_stack is
    l_stack_trace varchar2(4000);
    l_source_line varchar2(4000);
  begin
      l_stack_trace := q'[----- PL/SQL Call Stack -----
object      line  object
handle    number  name
00007FF8547B7D30       124  package body SCH_TEST.UT_EXPECTATION_PROCESSOR
00007FF8547B7D30        26  SCH_TEST.UT_EXPECTATION_RESULT
00007FF8547B7D30       112  SCH_TEST.UT_EXPECTATION
00007FF8547B7D30        21  SCH_TEST.UT_EXPECTATION_NUMBER
00007FF8547B7D30         7  package body SCOTT.TEST_BETWNSTR.BASIC_USAGE
00007FF81FF207B0       345  type body SCOTT.TEST_BETWNSTR.BASIC_USAGE_TYP
00007FF8544B21B8         6  anonymous block
00007FF8267FBFC8      1721  package body SYS.DBMS_SQL.EXECUTE
00007FF852BCFC68       142  type body UT3.UT_EXECUTABLE.DO_EXECUTE
00007FF852BCFC68        44  type body UT3.UT_EXECUTABLE.DO_EXECUTE
00007FF8512F9A90        74  type body UT3.UT_EXECUTABLE_TEST.DO_EXECUTE
00007FF8512F9A90        38  type body UT3.UT_EXECUTABLE_TEST.DO_EXECUTE
00007FF8231A2088        79  type body UT3.UT_TEST.DO_EXECUTE
00007FF81FF207B0        49  type body UT3.UT_SUITE_ITEM.DO_EXECUTE
00007FF852C83270        66  type body UT3.UT_SUITE.DO_EXECUTE
00007FF82165F3B0        67  type body UT3.UT_RUN.DO_EXECUTE
00007FF81FF207B0        49  type body UT3.UT_SUITE_ITEM.DO_EXECUTE
00007FF8266285C0       172  package body UT3.UT_RUNNER.RUN
00007FF854710538       134  package body UT3.UT.RUN_AUTONOMOUS
00007FF854710538       488  package body UT3.UT.RUN
00007FF854710538       623  package body UT3.UT.RUN
00007FF81CFFA388         1  anonymous block]';
      ut.expect(
        ut3.ut_expectation_processor.who_called_expectation(l_stack_trace)
        ).to_be_like('at "SCOTT.TEST_BETWNSTR.BASIC_USAGE", line 7 %');
  end;

end;
/
