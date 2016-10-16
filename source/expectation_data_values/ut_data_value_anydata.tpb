create or replace type body ut_data_value_anydata as

  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result is
  begin
    self.value := a_value;
    self.type := 'anydata';
    return;
  end;

  overriding member function is_null return boolean is
    l_is_null          boolean;
    l_data_is_null     pls_integer;
    l_type             anytype;
    l_anydata_accessor varchar2(30);
  begin
    if self.value is null then
      l_is_null := true;
    elsif self.value.gettypename like '%.%' then
    --XMLTYPE doesn't like the null beeing passed to ANYDATA so we need to check if anydata holds null Object/collection
    --check if typename is a schema based object
      l_anydata_accessor :=
        case when self.value.gettype(l_type) = dbms_types.typecode_object then 'getObject' else 'getCollection' end;
      execute immediate '
        declare
          l_data '||self.value.gettypename()||';
          l_value anydata := :a_value;
          x integer;
        begin
          x := l_value.'||l_anydata_accessor||'(l_data);
          :l_data_is_null := ut_utils.boolean_to_int(l_data is null);
        end;' using in self.value, out l_data_is_null;

      l_is_null := ut_utils.int_to_boolean(l_data_is_null);
    end if;
    return l_is_null;
  end;

  overriding member function to_string return varchar2 is
  begin
    return
      ut_utils.to_string(
        case
          when self.is_null() then to_clob(null)
          else xmltype(self.value).getclobval()
        end
      );
  end;


end;
/
