declare
  l_stack_trace varchar2(4000);
  l_source_line varchar2(4000);
begin
l_stack_trace := q'[----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
34f88e4420       124  package body SCH_TEST.UT_EXPECTATION_PROCESSOR
353dfeb2f8        26  SCH_TEST.UT_EXPECTATION_RESULT
cba249ce0       112  SCH_TEST.UT_EXPECTATION
3539881cf0        21  SCH_TEST.UT_EXPECTATION_NUMBER
351a608008        28  package body SCH_TEST.TPKG_PRIOR_YEAR_GENERATION
351a6862b8         6  anonymous block
351fe31010      1825  package body SYS.DBMS_SQL
20befbe4d8       129  SCH_TEST.UT_EXECUTABLE
20befbe4d8        65  SCH_TEST.UT_EXECUTABLE
34f8ab7cd8        80  SCH_TEST.UT_TEST
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
34f8ab9b10        74  SCH_TEST.UT_SUITE
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
cba24bfd0        75  SCH_TEST.UT_LOGICAL_SUITE
353dfecf30        59  SCH_TEST.UT_RUN
34f8ab98f0        48  SCH_TEST.UT_SUITE_ITEM
357f5421e8        77  package body SCH_TEST.UT_RUNNER
357f5421e8       111  package body SCH_TEST.UT_RUNNER
20be951ab0       292  package body SCH_TEST.UT
20be951ab0       320  package body SCH_TEST.UT
]';
  l_source_line := ut_expectation_processor.WHO_CALLED_EXPECTATION(l_stack_trace);
  if l_source_line like 'at "SCH_TEST.TPKG_PRIOR_YEAR_GENERATION", line 28 %' then
    :test_result := ut_utils.tr_success;
  end if;
end;
/
