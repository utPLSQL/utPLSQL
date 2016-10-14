create or replace type body ut_data_value_anydata as
  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result is
    l_data_is_null     pls_integer;
    l_type             anytype;
    l_anydata_accessor varchar2(30);
  begin
    --XMLTYPE doesn't like the null beeing passed to ANYDATA so we need to check if anydata holds null Object/collection

    --check if typename is a schema based object
    if a_value.gettypename like '%.%' then
      l_anydata_accessor :=
        case when a_value.gettype(l_type) = dbms_types.typecode_object then 'getObject' else 'getCollection' end;
      execute immediate '
        declare
          l_data '||a_value.gettypename()||';
          l_value anydata := :a_value;
          x integer;
        begin
          x := l_value.'||l_anydata_accessor||'(l_data);
          :l_data_is_null := ut_utils.boolean_to_int(l_data is null);
        end;' using in a_value, out l_data_is_null;
    end if;
    self.value := a_value;
    self.init(
      'anydata',
      l_data_is_null,
      ut_utils.to_string(
        case when ut_utils.int_to_boolean(l_data_is_null) then to_clob(null)
          else xmltype(a_value).getclobval() end
      )
    );
    return;
  end;
end;
/
