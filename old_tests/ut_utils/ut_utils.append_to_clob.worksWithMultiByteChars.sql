column nls_lang noprint new_value v_nls_lang

select value as nls_lang from nls_session_parameters where parameter = 'NLS_DATE_LANGUAGE';

--Arrange
alter session set nls_date_language=ENGLISH;
create or replace package tst_chars as
--                 2) Status of the process = ‘PE’ with no linked data
end;
/

alter session set nls_date_language=RUSSIAN;

--Act
declare
  l_lines   sys.dbms_preprocessor.source_lines_t;
  l_result  clob;
begin
  l_lines := sys.dbms_preprocessor.get_post_processed_source(
    object_type => 'PACKAGE',
    schema_name => user,
    object_name => 'TST_CHARS'
  );
  :test_result := ut_utils.gc_success;
  for i in 1..l_lines.count loop
    l_result := null;
    ut_utils.append_to_clob(l_result, l_lines(i));

    --Assert
    :test_result := coalesce(:test_result, ut_utils.gc_success);
    if dbms_lob.getlength(l_result) != dbms_lob.getlength(l_lines(i)) then
      :test_result := ut_utils.gc_failure;
      dbms_output.put_line('Expected: "'||l_lines(i)||'"');
      dbms_output.put_line('Actual: "'||l_result||'"');
    end if;
  end loop;
end;
/

alter session set nls_date_language=&&v_nls_lang;

undef v_nls_lang;
drop package tst_chars;
