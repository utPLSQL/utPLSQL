PROMPT Saves and retrieves cached annotation data in an unchanged form
declare
  l_expected ut_annotations.typ_annotated_package;
  l_actual   ut_annotations.typ_annotated_package;
  i ut_annotations.t_annotation_name;
  j ut_annotations.t_procedure_name;
begin
  --Arrange
  l_expected := ut_annotations.parse_package_annotations( ut_metadata.get_package_spec_source(user, 'UT_EXAMPLE_TESTS') );
  --Act
  ut_annotations_cache.update_cache(user, 'UT_EXAMPLE_TESTS', l_expected);
  l_actual := ut_annotations_cache.get_cache_data(user, 'UT_EXAMPLE_TESTS');
  --Assert
  :test_result := ut_utils.tr_success;
  i := l_expected.procedure_annotations.first;
  while i is not null loop
    j := l_expected.procedure_annotations(i).first;
    while j is not null loop
      if l_expected.procedure_annotations(i)(j) is not null then
        for k in 1 .. l_expected.procedure_annotations(i)(j).count loop
          if not (
               ( l_expected.procedure_annotations(i)(j)(k).key = l_actual.procedure_annotations(i)(j)(k).key
                  or (l_expected.procedure_annotations(i)(j)(k).key is null
                      and l_actual.procedure_annotations(i)(j)(k).key is null) )
               and ( l_expected.procedure_annotations(i)(j)(k).value = l_actual.procedure_annotations(i)(j)(k).value
                  or (l_expected.procedure_annotations(i)(j)(k).value is null
                      and l_actual.procedure_annotations(i)(j)(k).value is null) ) ) then
            dbms_output.put_line('expected: '||i||','||j||','||k||','||l_expected.procedure_annotations(i)(j)(k).key
              ||'='||l_expected.procedure_annotations(i)(j)(k).value
              ||''', got: '''||l_actual.procedure_annotations(i)(j)(k).key||'='||l_actual.procedure_annotations(i)(j)(k).value||'''' );
            :test_result := ut_utils.tr_failure;
          end if;
        end loop;
      end if;
      j := l_expected.procedure_annotations(i).next(j);
    end loop;
    i := l_expected.procedure_annotations.next(i);
  end loop;
  i := l_expected.package_annotations.first;
  while i is not null loop
    if l_expected.package_annotations(i) is not null then
      for j in 1 .. l_expected.package_annotations(i).count loop
        if not (
             ( l_expected.package_annotations(i)(j).key = l_actual.package_annotations(i)(j).key
                or (l_expected.package_annotations(i)(j).key is null
                    and l_actual.package_annotations(i)(j).key is null) )
             and ( l_expected.package_annotations(i)(j).value = l_actual.package_annotations(i)(j).value
                or (l_expected.package_annotations(i)(j).value is null
                    and l_actual.package_annotations(i)(j).value is null) ) ) then
          dbms_output.put_line('expected: '||i||','||j||','||l_expected.package_annotations(i)(j).key
            ||'='||l_expected.package_annotations(i)(j).value
            ||''', got: '''||l_actual.package_annotations(i)(j).key||'='||l_actual.package_annotations(i)(j).value||'''' );
          :test_result := ut_utils.tr_failure;
        end if;
      end loop;
    end if;
    i := l_expected.package_annotations.next(i);
  end loop;
end;
/
