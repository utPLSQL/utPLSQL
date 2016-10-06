PROMPT Trims long Blob to max lenght and appends '[...]' at the end of string;

--Arrange
declare
  l_text     clob := lpad('A test char',32767,'1')||lpad('1',32767,'1');
  l_value    blob;
  l_result   varchar2(32767);
  l_delimiter varchar2(1);
  function clob_to_blob(p_clob clob) return blob
  as
    l_blob          blob;
    l_dest_offset   integer := 1;
    l_source_offset integer := 1;
    l_lang_context  integer := dbms_lob.default_lang_ctx;
    l_warning       integer := dbms_lob.warn_inconvertible_char;
  begin
    dbms_lob.createtemporary(l_blob, true);
    dbms_lob.converttoblob(
      dest_lob    =>l_blob,
      src_clob    =>p_clob,
      amount      =>DBMS_LOB.LOBMAXSIZE,
      dest_offset =>l_dest_offset,
      src_offset  =>l_source_offset,
      blob_csid   =>DBMS_LOB.DEFAULT_CSID,
      lang_context=>l_lang_context,
      warning     =>l_warning
    );
    return l_blob;
  end;
begin
  l_value := clob_to_blob(l_text);

--Act
  l_result :=  ut_utils.to_String(l_value);
--Assert
  if length(l_result) != ut_utils.gc_max_output_string_length then
    dbms_output.put_line('expected: length(l_result)='||ut_utils.gc_max_output_string_length||', got: '||length(l_result) );
  elsif l_result not like '%'||ut_utils.gc_more_data_string then
    dbms_output.put_line('expected: l_result to match %'||ut_utils.gc_more_data_string||', got: '||substr(l_result,-10) );
  else
    :test_result := ut_utils.tr_success;
  end if;
end;
/
