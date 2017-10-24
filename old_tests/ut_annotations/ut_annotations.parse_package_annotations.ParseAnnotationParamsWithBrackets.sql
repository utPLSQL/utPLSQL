PROMPT Parse package level annotations with annotation params containing brackets

--Arrange
declare
  l_source clob;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param  := null;
  l_results ut_expectation_results;
begin
  l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite (including some brackets) and some more text)
END;';

--Act
  l_parsing_result := ut_annotations.parse_package_annotations(l_source);

--Assert
  l_ann_param.val := 'Name of suite (including some brackets) and some more text';
  l_expected.package_annotations('suite').params(1) := l_ann_param;

  check_annotation_parsing(l_expected, l_parsing_result);

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  else
    l_results := ut_expectation_processor.get_failed_expectations();
    for i in 1 .. l_results.count loop
      dbms_output.put_line(l_results(i).message);
    end loop;
  end if;

end;
/
