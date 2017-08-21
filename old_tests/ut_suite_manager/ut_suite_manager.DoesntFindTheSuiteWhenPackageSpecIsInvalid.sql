set termout off
create or replace package failing_invalid_spec as
  --%suite
  gv_glob_val non_existing_table.id%type := 0;

  --%beforeall
  procedure before_all;
  --%test
  procedure test1;
  --%test
  procedure test2;
end;
/
create or replace package body failing_invalid_spec as
  procedure before_all is begin gv_glob_val := 1; end;
  procedure test1 is begin ut.expect(1).to_equal(1); end;
  procedure test2 is begin ut.expect(1).to_equal(1); end;
end;
/
set termout on

declare
  l_objects_to_run ut_suite_items;
begin
  begin
  --act
    l_objects_to_run := ut_suite_manager.configure_execution_by_path(ut_varchar2_list('failing_invalid_spec'));
  exception
    when others then
      if sqlerrm like '%failing_invalid_spec%' then
        :test_result := ut_utils.tr_success;
      end if;
  end;

  if :test_result != ut_utils.tr_success or :test_result is null then
    dbms_output.put_line('Failed: Expected exception with text like ''%failing_invalid_spec%'' but got:'''||sqlerrm||'''');
  end if;
end;
/

drop package failing_invalid_spec
/
