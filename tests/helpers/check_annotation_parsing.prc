create or replace procedure check_annotation_parsing(a_expected ut_annotations.typ_annotated_package, a_parsing_result ut_annotations.typ_annotated_package) is
  procedure check_annotation_params(a_msg varchar2, a_expected ut_annotations.tt_annotation_params, a_actual ut_annotations.tt_annotation_params) is
  begin
    ut.expect(a_actual.count,'['||a_msg||']Check number of annotation params').to_equal(a_expected.count);

    if a_expected.count = a_actual.count and a_expected.count > 0 then
      for i in 1..a_expected.count loop
        if a_expected(i).key is not null then
          ut.expect(a_actual(i).key,'['||a_msg||'('||i||')]Check annotation param key').to_equal(a_expected(i).key);
        else
          ut.expect(a_actual(i).key,'['||a_msg||'('||i||')]Check annotation param key').to_be_null;
        end if;

        if a_expected(i).val is not null then
          ut.expect(a_actual(i).val,'['||a_msg||'('||i||')]Check annotation param value').to_equal(a_expected(i).val);
        else
          ut.expect(a_actual(i).val,'['||a_msg||'('||i||')]Check annotation param value').to_be_null;
        end if;
      end loop;
    end if;
  end;

  procedure check_annotations(a_msg varchar2, a_expected ut_annotations.tt_annotations, a_actual ut_annotations.tt_annotations) is
    l_ind varchar2(500);
  begin
    ut.expect(a_actual.count,'['||a_msg||']Check number of annotations parsed').to_equal(a_expected.count);

    if a_expected.count = a_actual.count and a_expected.count > 0 then
      l_ind := a_expected.first;
      while l_ind is not null loop

        ut.expect(a_actual.exists(l_ind),('['||a_msg||']Check annotation exists')).to_be_true;
        if a_actual.exists(l_ind) then
          check_annotation_params(a_msg||'.'||l_ind,a_expected(l_ind),a_actual(l_ind));
        end if;
        l_ind := a_expected.next(l_ind);
      end loop;
    end if;
  end;

  procedure check_procedures(a_msg varchar2,  a_expected ut_annotations.tt_procedure_list, a_actual ut_annotations.tt_procedure_list) is
    l_found boolean := false;
    l_index pls_integer;
  begin
    ut.expect(a_actual.count,'['||a_msg||']Check number of procedures parsed').to_equal(a_expected.count);

    if a_expected.count = a_actual.count and a_expected.count > 0 then
      for i in 1..a_expected.count loop
        l_found := false;
        l_index := null;
        for j in 1..a_actual.count loop
          if a_expected(i).name = a_actual(j).name then
            l_found:=true;
            l_index := j;
            exit;
          end if;
        end loop;

        ut.expect(l_found,'['||a_msg||']Check procedure exists').to_be_true;
        if l_found then
          check_annotations(a_msg||'.'||a_expected(i).name,a_expected(i).annotations,a_actual(l_index).annotations);
        end if;
      end loop;
    end if;
  end;
begin
  check_annotations('PACKAGE',a_expected.package_annotations,a_parsing_result.package_annotations);
  check_procedures('PROCEDURES',a_expected.procedure_annotations,a_parsing_result.procedure_annotations);
end check_annotation_parsing;
/
