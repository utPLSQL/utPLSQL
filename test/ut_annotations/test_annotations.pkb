create or replace package body test_annotations is

  procedure check_annotation_parsing(a_expected ut3.ut_annotations.typ_annotated_package, a_parsing_result ut3.ut_annotations.typ_annotated_package) is
  
    procedure check_annotation_params(a_msg varchar2, a_expected ut3.ut_annotations.tt_annotation_params, a_actual ut3.ut_annotations.tt_annotation_params) is
    begin
      ut.expect(a_actual.count, '[' || a_msg || ']Check number of annotation params').to_equal(a_expected.count);
    
      if a_expected.count = a_actual.count and a_expected.count > 0 then
        for i in 1 .. a_expected.count loop
          if a_expected(i).key is not null then
            ut.expect(a_actual(i).key, '[' || a_msg || '(' || i || ')]Check annotation param key').to_equal(a_expected(i).key);
          else
            ut.expect(a_actual(i).key, '[' || a_msg || '(' || i || ')]Check annotation param key').to_be_null;
          end if;
        
          if a_expected(i).val is not null then
            ut.expect(a_actual(i).val, '[' || a_msg || '(' || i || ')]Check annotation param value').to_equal(a_expected(i).val);
          else
            ut.expect(a_actual(i).val, '[' || a_msg || '(' || i || ')]Check annotation param value').to_be_null;
          end if;
        end loop;
      end if;
    end;
  
    procedure check_annotations(a_msg varchar2, a_expected ut3.ut_annotations.tt_annotations, a_actual ut3.ut_annotations.tt_annotations) is
      l_ind varchar2(500);
    begin
      ut.expect(a_actual.count, '[' || a_msg || ']Check number of annotations parsed').to_equal(a_expected.count);
    
      if a_expected.count = a_actual.count and a_expected.count > 0 then
        l_ind := a_expected.first;
        while l_ind is not null loop
        
          ut.expect(a_actual.exists(l_ind), ('[' || a_msg || ']Check annotation exists')).to_be_true;
          if a_actual.exists(l_ind) then
            check_annotation_params(a_msg || '.' || l_ind, a_expected(l_ind).params, a_actual(l_ind).params);
          end if;
          l_ind := a_expected.next(l_ind);
        end loop;
      end if;
    end;
  
    procedure check_procedures(a_msg varchar2, a_expected ut3.ut_annotations.tt_procedure_list, a_actual ut3.ut_annotations.tt_procedure_list) is
      l_found boolean := false;
      l_index pls_integer;
    begin
      ut.expect(a_actual.count, '[' || a_msg || ']Check number of procedures parsed').to_equal(a_expected.count);
    
      if a_expected.count = a_actual.count and a_expected.count > 0 then
        for i in 1 .. a_expected.count loop
          l_found := false;
          l_index := null;
          for j in 1 .. a_actual.count loop
            if a_expected(i).name = a_actual(j).name then
              l_found := true;
              l_index := j;
              exit;
            end if;
          end loop;
        
          ut.expect(l_found, '[' || a_msg || ']Check procedure exists').to_be_true;
          if l_found then
            check_annotations(a_msg || '.' || a_expected(i).name
                             ,a_expected(i).annotations
                             ,a_actual(l_index).annotations);
          end if;
        end loop;
      end if;
    end;
  begin
    check_annotations('PACKAGE', a_expected.package_annotations, a_parsing_result.package_annotations);
    check_procedures('PROCEDURES', a_expected.procedure_annotations, a_parsing_result.procedure_annotations);
  end check_annotation_parsing;

  procedure test1 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    -- %ann1(Name of suite)
    -- wrong line
    -- %ann2(some_value)  
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
    l_expected.package_annotations('displayname').text := l_ann_param.val;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
    l_expected.package_annotations('suitepath').text := l_ann_param.val;
  
    l_ann_param := null;
    l_ann_param.val := 'some_value';
    l_expected.procedure_annotations(1).name := 'foo';
    l_expected.procedure_annotations(1).annotations('ann2').params(1) := l_ann_param;
    l_expected.procedure_annotations(1).annotations('ann2').text := l_ann_param.val;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test2 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    -- %ann1(Name of suite)
    -- %ann2(all.globaltests)  
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test3 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    --%test
    procedure foo;
    
    
    --%beforeeach
    procedure foo2;
    
    --test comment
    -- wrong comment
    
    
    /*
    describtion of the procedure
    */
    --%beforeeach(key=testval)
    PROCEDURE foo3(a_value number default null);
    
    function foo4(a_val number default null
      , a_par varchar2 default := ''asdf'');
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    l_expected.procedure_annotations(1).name := 'foo';
    l_expected.procedure_annotations(1).annotations('test').params := cast(null as ut3.ut_annotations.tt_annotation_params);
  
    l_expected.procedure_annotations(2).name := 'foo2';
    l_expected.procedure_annotations(2).annotations('beforeeach').params := cast(null as
                                                                                 ut3.ut_annotations.tt_annotation_params);
  
    l_ann_param     := null;
    l_ann_param.key := 'key';
    l_ann_param.val := 'testval';
  
    l_expected.procedure_annotations(3).name := 'foo3';
    l_expected.procedure_annotations(3).annotations('beforeeach').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test4 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    --%test
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    l_expected.procedure_annotations(1).name := 'foo';
    l_expected.procedure_annotations(1).annotations('test').params := cast(null as ut3.ut_annotations.tt_annotation_params);
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test5 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test6 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt accessible by (foo) AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test7 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt 
    ACCESSIBLE BY (calling_proc)
    authid current_user 
    AS
    -- %suite
    -- %displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test8 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    -- %suite
    --%displayname(name = Name of suite)
    -- %suitepath(key=all.globaltests,key2=foo)
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.key := 'name';
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.key := 'key';
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.key := 'key2';
    l_ann_param.val := 'foo';
    l_expected.package_annotations('suitepath').params(2) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure test9 is
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param;
  
  begin
    l_source := 'PACKAGE test_tt AS
    /*
    Some comment
    -- inlined
    */
    -- %suite
    --%displayname(Name of suite)
    -- %suitepath(all.globaltests)
    
    procedure foo;
  END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast(null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  
  end;

  procedure ignore_wrapped_package is
    l_pck_annotation ut3.ut_annotations.typ_annotated_package;
    pragma autonomous_transaction;
  begin
  
    l_pck_annotation := ut3.ut_annotations.get_package_annotations(user, 'TST_WRAPPED_PCK');
    ut.expect(l_pck_annotation.procedure_annotations.count).to_equal(0);
    ut.expect(l_pck_annotation.package_annotations.count).to_equal(0);
  
  end;

  procedure cre_wrapped_pck is
    pragma autonomous_transaction;
  begin
    dbms_ddl.create_wrapped(q'[
CREATE OR REPLACE PACKAGE tst_wrapped_pck IS
  PROCEDURE dummy;
END;
]');
  end;

  procedure drop_wrapped_pck is
    ex_pck_doesnt_exist exception;
    pragma autonomous_transaction;
    pragma exception_init(ex_pck_doesnt_exist, -04043);
  begin
    execute immediate 'drop package tst_wrapped_pck';
  exception
    when ex_pck_doesnt_exist then
      null;
  end;

  procedure brackets_in_desc is
  
    l_source         clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected       ut3.ut_annotations.typ_annotated_package;
    l_ann_param      ut3.ut_annotations.typ_annotation_param := null;
    --l_results        ut_expectation_results;
  begin
    l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite (including some brackets) and some more text)
END;';
  
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
  
    --Assert
    l_ann_param.val := 'Name of suite (including some brackets) and some more text';
    l_expected.package_annotations('suite').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  end;
  
  procedure test_space_Before_Annot_Params is
    l_source clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected ut3.ut_annotations.typ_annotated_package;
    l_ann_param ut3.ut_annotations.typ_annotation_param;

  begin
    l_source := 'PACKAGE test_tt AS
  /*
  Some comment
  -- inlined
  */
  -- %suite
  -- %suitepath (all.globaltests)

  procedure foo;
END;';

  --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);

  --Assert
    l_expected.package_annotations('suite').params := cast( null as ut3.ut_annotations.tt_annotation_params);

    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;

    check_annotation_parsing(l_expected, l_parsing_result);
  end;

  procedure test_windows_newline
  as
    l_source clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected ut3.ut_annotations.typ_annotated_package;
    l_ann_param ut3.ut_annotations.typ_annotation_param;
  begin
    l_source := 'PACKAGE test_tt AS
        -- %suite
        -- %displayname(Name of suite)' || chr(13) || chr(10) 
      || '  -- %suitepath(all.globaltests)
      END;';

    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);

    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast( null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    check_annotation_parsing(l_expected, l_parsing_result);
  end;

  procedure test_annot_very_long_name
  as
    l_source clob;
    l_parsing_result ut3.ut_annotations.typ_annotated_package;
    l_expected ut3.ut_annotations.typ_annotated_package;
    l_ann_param ut3.ut_annotations.typ_annotation_param;
  begin
    l_source := 'PACKAGE test_tt AS
      -- %suite
      -- %displayname(Name of suite)
      -- %suitepath(all.globaltests)
    
      --%test
      procedure very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit;
    END;';
    
    --Act
    l_parsing_result := ut3.ut_annotations.parse_package_annotations(l_source);
    
    --Assert
    l_ann_param := null;
    l_ann_param.val := 'Name of suite';
    l_expected.package_annotations('suite').params := cast( null as ut3.ut_annotations.tt_annotation_params);
    l_expected.package_annotations('displayname').params(1) := l_ann_param;
    
    l_ann_param := null;
    l_ann_param.val := 'all.globaltests';
    l_expected.package_annotations('suitepath').params(1) := l_ann_param;
  
    l_expected.procedure_annotations(1).name := 'very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit';
    l_expected.procedure_annotations(1).annotations('test').params := cast( null as ut3.ut_annotations.tt_annotation_params);
  
    check_annotation_parsing(l_expected, l_parsing_result);
  end;


end test_annotations;
/
