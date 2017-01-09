create or replace type body ut_data_value_anydata as

  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result is
  begin
    self.data_value := a_value;
    self.data_type  := case when a_value is not null then lower(a_value.gettypename) else 'none' end;
    return;
  end;

  overriding member function is_null return boolean is
    l_is_null          boolean;
    l_data_is_null     pls_integer;
    l_type             anytype;
    l_anydata_accessor varchar2(30);
    l_sql varchar2(32767);
    l_cursor number;
    l_status number;
  begin
    if self.data_value is null then
      l_is_null := true;
    --check if typename is a schema based object
    elsif self.data_value.gettypename like '%.%' then
      --XMLTYPE doesn't like the null beeing passed to ANYDATA so we need to check if anydata holds null Object/collection
      l_anydata_accessor :=
        case when self.data_value.gettype(l_type) = sys.dbms_types.typecode_object then 'getObject' else 'getCollection' end;
        
        l_sql := '
        declare
          l_data '||self.data_value.gettypename()||';
          l_value anydata := :a_value;
          x integer;
        begin
          x := l_value.'||l_anydata_accessor||'(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end;
        end;';
        l_cursor := sys.dbms_sql.open_cursor();
        sys.dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
        sys.dbms_sql.bind_variable(l_cursor,'a_value',self.data_value);
        sys.dbms_sql.bind_variable(l_cursor,'l_data_is_null',l_data_is_null);
        begin
          l_status := sys.dbms_sql.execute(l_cursor);
          sys.dbms_sql.variable_value(l_cursor,'l_data_is_null',l_data_is_null);
          sys.dbms_sql.close_cursor(l_cursor);
        exception when others then
          if sys.dbms_sql.is_open(l_cursor) then
            sys.dbms_sql.close_cursor(l_cursor);
          end if;
          raise;
        end;

      l_is_null := ut_utils.int_to_boolean(l_data_is_null);
    end if;
    return l_is_null;
  end;

  overriding member function to_string return varchar2 is
    l_result varchar2(32767);
    l_clob   clob;
  begin
    if self.is_null() then
      l_result := ut_utils.to_string( to_char(null) );
    else
      ut_assert_processor.set_xml_nls_params();
      select xmlserialize(content xmltype(self.data_value) indent) into l_clob from dual;
      l_result := ut_utils.to_string( l_clob );
      ut_assert_processor.reset_nls_params();
    end if;
    return l_result;
  end;

end;
/
