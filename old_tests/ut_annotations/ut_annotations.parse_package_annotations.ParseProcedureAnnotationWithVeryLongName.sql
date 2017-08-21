PROMPT Parse PROCEDURE Annotation with very long name

--Arrange
declare
  l_source clob;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param;

begin
  l_source := 'PACKAGE test_tt AS
  -- %suite
  -- %displayname(Name of suite)
  -- %suitepath(all.globaltests)

  --%test
  procedure very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit;
END;';

--Act
  l_parsing_result := ut_annotations.parse_package_annotations(l_source);

--Assert
  l_ann_param := null;
  l_ann_param.val := 'Name of suite';
  l_expected.package_annotations('suite').params := cast( null as ut_annotations.tt_annotation_params);
  l_expected.package_annotations('displayname').params(1) := l_ann_param;
  
  l_ann_param := null;
  l_ann_param.val := 'all.globaltests';
  l_expected.package_annotations('suitepath').params(1) := l_ann_param;

  l_expected.procedure_annotations(1).name := 'very_long_procedure_name_valid_for_oracle_12_so_utplsql_should_allow_it_definitely_well_still_not_reached_128_but_wait_we_ditit';
  l_expected.procedure_annotations(1).annotations('test').params := cast( null as ut_annotations.tt_annotation_params);

  check_annotation_parsing(l_expected, l_parsing_result);

  if ut_expectation_processor.get_status = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
