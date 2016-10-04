create or replace procedure check_annotation_parsing(a_expected ut_annotations.typ_annotated_package, a_parsing_result ut_annotations.typ_annotated_package) is
  procedure check_annotation_params(a_msg varchar2, a_expected ut_annotations.tt_annotation_params, a_actual ut_annotations.tt_annotation_params) is
  begin
    ut_assert.are_equal('['||a_msg||']Check number of annotation params', a_expected.count, a_actual.count);
    
    if a_expected.count = a_actual.count and a_expected.count > 0 then
      for i in 1..a_expected.count loop
        if a_expected(i).key is not null then
          ut_assert.are_equal('['||a_msg||'('||i||')]Check annotation param key',a_expected(i).key,a_actual(i).key);
        else
          ut_assert.is_null('['||a_msg||'('||i||')]Check annotation param key',a_actual(i).key);
        end if;
        
        if a_expected(i).value is not null then
          ut_assert.are_equal('['||a_msg||'('||i||')]Check annotation param value',a_expected(i).value,a_actual(i).value);
        else
          ut_assert.is_null('['||a_msg||'('||i||')]Check annotation param value',a_actual(i).value);
        end if;
      end loop;
    end if;
  end;
  
  procedure check_annotations(a_msg varchar2, a_expected ut_annotations.tt_annotations, a_actual ut_annotations.tt_annotations) is
    l_ind varchar2(500);
  begin
    ut_assert.are_equal('['||a_msg||']Check number of annotations parsed',a_expected.count,a_actual.count);
    
    if a_expected.count = a_actual.count and a_expected.count > 0 then
      l_ind := a_expected.first;
      while l_ind is not null loop
        
        ut_assert.this('['||a_msg||']Check annotation exists', a_actual.exists(l_ind));
        if a_actual.exists(l_ind) then
          check_annotation_params(a_msg||'.'||l_ind,a_expected(l_ind),a_actual(l_ind));
        end if;
        l_ind := a_expected.next(l_ind);
      end loop;
    end if;
  end;
  
  procedure check_procedures(a_msg varchar2,  a_expected ut_annotations.tt_procedure_annotations, a_actual ut_annotations.tt_procedure_annotations) is
    l_ind varchar2(500);
  begin
    ut_assert.are_equal('['||a_msg||']Check number of procedures parsed',a_expected.count,a_actual.count);
    
    if a_expected.count = a_actual.count and a_expected.count > 0 then
      l_ind := a_expected.first;
      while l_ind is not null loop
        
        ut_assert.this('['||a_msg||']Check procedure exists', a_actual.exists(l_ind));
        if a_actual.exists(l_ind) then
          check_annotations(a_msg||'.'||l_ind,a_expected(l_ind),a_actual(l_ind));
        end if;
        l_ind := a_expected.next(l_ind);
      end loop;
    end if;
  end;
begin
  check_annotations('PACKAGE',a_expected.package_annotations,a_parsing_result.package_annotations);
  check_procedures('PROCEDURES',a_expected.procedure_annotations,a_parsing_result.procedure_annotations);
end check_annotation_parsing;
/
