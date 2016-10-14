PROMPT Parse complex package

--Arrange
declare
  l_source clob;
  l_parsing_result ut_annotations.typ_annotated_package;
  l_expected ut_annotations.typ_annotated_package;
  l_ann_param ut_annotations.typ_annotation_param;

begin
  l_source := 'PACKAGE test_tt AS
  -- %suite(Name of suite)
  -- %suitepackage(all.globaltests)
  
  --%test
  procedure foo;
  
  
  --%setup
  procedure foo2;
  
  --test comment
  -- wrong comment
  
  
  /*
  describtion of the procedure
  */
  --%setup(key=testval)
  PROCEDURE foo3(a_value number default null);
  
  function foo4(a_val number default null
    , a_par varchar2 default := ''asdf'');
END;';

--Act
  l_parsing_result := ut_annotations.parse_package_annotations(l_source);
  
--Assert
  l_ann_param := null;
  l_ann_param.value := 'Name of suite'; 
  l_expected.package_annotations('suite')(1) := l_ann_param;
  
  l_ann_param := null;
  l_ann_param.value := 'all.globaltests';  
  l_expected.package_annotations('suitepackage')(1) := l_ann_param;
  
  l_expected.procedure_annotations('foo')('test') := cast( null as ut_annotations.tt_annotation_params);
  l_expected.procedure_annotations('foo2')('setup') := cast( null as ut_annotations.tt_annotation_params);
  
  l_ann_param := null;
  l_ann_param.key := 'key'; 
  l_ann_param.value := 'testval'; 
  l_expected.procedure_annotations('foo3')('setup')(1) := l_ann_param;
  
  check_annotation_parsing(l_expected, l_parsing_result);
  
  if ut_assert_processor.get_aggregate_asserts_result = ut_utils.tr_success then
    :test_result := ut_utils.tr_success;
  end if;

end;
/
