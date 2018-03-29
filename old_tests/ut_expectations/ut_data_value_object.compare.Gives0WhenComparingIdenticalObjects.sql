--Arrange
declare
  l_expected department$ := department$('HR');
  l_actual   department$ := department$('HR');
  l_result   integer;
begin
--Act
  l_result :=
    ut_data_value_object(
      anydata.convertObject(l_actual)
    ).compare_implementation(
      ut_data_value_object(
        anydata.convertObject(l_expected))
    );
--Assert
  if l_result = 0 then
    :test_result := ut_utils.gc_success;
  else
    dbms_output.put_line( 'Expected comparison to give 0, got '||l_result );
  end if;
end;
/
