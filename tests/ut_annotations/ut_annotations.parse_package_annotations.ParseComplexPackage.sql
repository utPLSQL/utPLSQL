PROMPT Parse complex package

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
  l_parsing_result := ut_annotations.parse_package_annotations(l_source);

--Assert
  l_ann_param := null;
  l_ann_param.val := 'Name of suite';
  l_expected.package_annotations('suite') := cast( null as ut_annotations.tt_annotation_params);
  l_expected.package_annotations('displayname')(1) := l_ann_param;

  l_ann_param := null;
  l_ann_param.val := 'all.globaltests';
  l_expected.package_annotations('suitepath')(1) := l_ann_param;

  l_expected.procedure_annotations(1).name := 'foo';
  l_expected.procedure_annotations(1).annotations('test') := cast( null as ut_annotations.tt_annotation_params);

  l_expected.procedure_annotations(2).name := 'foo2';
  l_expected.procedure_annotations(2).annotations('beforeeach') := cast( null as ut_annotations.tt_annotation_params);

  l_ann_param := null;
  l_ann_param.key := 'key';
  l_ann_param.val := 'testval';

  l_expected.procedure_annotations(3).name := 'foo3';
  l_expected.procedure_annotations(3).annotations('beforeeach')(1) := l_ann_param;

  check_annotation_parsing(l_expected, l_parsing_result);

  if ut_expectation_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
