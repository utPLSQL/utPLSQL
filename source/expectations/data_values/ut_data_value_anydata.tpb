create or replace type body ut_data_value_anydata as

  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result is
  begin
    self.datavalue := a_value;
    self.datatype  := case when a_value is not null then lower(a_value.gettypename) else 'null' end;
    return;
  end;

  overriding member function is_null return boolean is
    l_is_null          boolean;
    l_data_is_null     pls_integer;
    l_type             anytype;
    l_anydata_accessor varchar2(30);
  begin
    if self.datavalue is null then
      l_is_null := true;
    --check if typename is a schema based object
    elsif self.datavalue.gettypename like '%.%' then
      --XMLTYPE doesn't like the null beeing passed to ANYDATA so we need to check if anydata holds null Object/collection
      l_anydata_accessor :=
        case when self.datavalue.gettype(l_type) = dbms_types.typecode_object then 'getObject' else 'getCollection' end;
      execute immediate '
        declare
          l_data '||self.datavalue.gettypename()||';
          l_value anydata := :a_value;
          x integer;
        begin
          x := l_value.'||l_anydata_accessor||'(l_data);
          :l_data_is_null := ut_utils.boolean_to_int(l_data is null);
        end;' using in self.datavalue, out l_data_is_null;

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
      select xmlserialize(content xmltype(self.datavalue) indent) into l_clob from dual;
      l_result := ut_utils.to_string( l_clob );
      ut_assert_processor.reset_nls_params();
    end if;
    return l_result;
  end;

end;
/
