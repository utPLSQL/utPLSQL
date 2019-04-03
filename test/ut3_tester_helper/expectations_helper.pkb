create or replace package body expectations_helper is

  function unary_expectation_block(
    a_matcher_name varchar2,
    a_data_type    varchar2,
    a_data_value   varchar2
  ) return varchar2 is
    l_execute varchar2(32000);
  begin
    l_execute := '
      declare
        l_expected '||a_data_type||' := '||a_data_value||';
      begin
        --act - execute the expectation
        ut3.ut.expect(l_expected).'||a_matcher_name||'();
      end;';
      return l_execute;
  end;

  function unary_expectation_object_block(
    a_matcher_name varchar2,
    a_object_name  varchar2,
    a_object_value varchar2,
    a_object_type  varchar2
  ) return varchar2 is
  begin
    return '
      declare
        l_object '||a_object_name||' := '||a_object_value||';
      begin
        ut3.ut.expect(anydata.convert'||a_object_type||'(l_object)).'||a_matcher_name||'();
      end;';
  end;

  function binary_expectation_block(
    a_matcher_name       varchar2,
    a_actual_data_type   varchar2,
    a_actual_data        varchar2,
    a_expected_data_type varchar2,
    a_expected_data      varchar2
  ) return varchar2
  is
    l_execute varchar2(32000);
  begin
    l_execute := '
      declare
        l_actual   '||a_actual_data_type||' := '||a_actual_data||';
        l_expected '||a_expected_data_type||' := '||a_expected_data||';
      begin
        --act - execute the expectation
        ut3.ut.expect( l_actual ).'||a_matcher_name||'(l_expected);
      end;';
    return l_execute;
  end;
  
end;
/
