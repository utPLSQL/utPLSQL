create or replace type body ut_data_value_anydata as
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2018 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  final member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata, a_data_object_type varchar2, a_extract_path varchar2) is
    l_query    sys_refcursor;
    l_ctx      number;
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
  begin
    self.data_type  := case when a_value is not null then lower(a_value.gettypename) else 'undefined' end;
    self.data_id    := sys_guid();
    if a_value is not null then
      execute immediate '
        declare
          l_data '||self.data_type||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.get'||a_data_object_type||'(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end;
        end;' using in a_value, out self.is_data_null;
    else
      self.is_data_null := 1;
    end if;
    if not self.is_null() then
      ut_expectation_processor.set_xml_nls_params();
      open l_query for select a_value val from dual;
      l_ctx := sys.dbms_xmlgen.newcontext( l_query );
      dbms_xmlgen.setrowtag(l_ctx, '');
      dbms_xmlgen.setrowsettag(l_ctx, '');
      dbms_xmlgen.setnullhandling(l_ctx,2);
      execute immediate
      'insert into ' || l_ut_owner || '.ut_compound_data_tmp(data_id, item_no, item_data) ' ||
      'select :self_guid, rownum, value(a) ' ||
      '  from table( xmlsequence( extract(:l_xml, :xpath ) ) ) a'
      using in self.data_id, dbms_xmlgen.getXMLtype(l_ctx), a_extract_path;
      self.elements_count := sql%rowcount;
      dbms_xmlgen.closecontext (l_ctx);
      ut_expectation_processor.reset_nls_params();
    end if;
  end;

  static function get_instance(a_data_value anydata) return ut_data_value_anydata is
    l_result    ut_data_value_anydata := ut_data_value_object(null);
    l_type      anytype;
    l_type_code integer;
  begin
    if a_data_value is not null then
      l_type_code := a_data_value.gettype(l_type);
      if l_type_code in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection, dbms_types.typecode_object) then
        if l_type_code = dbms_types.typecode_object then
          l_result := ut_data_value_object(a_data_value);
        else
          l_result := ut_data_value_collection(a_data_value);
        end if;
      else
        raise_application_error(-20000, 'Data type '||a_data_value.gettypename||' in ANYDATA is not supported by utPLSQL');
      end if;
    end if;
    return l_result;
  end;

end;
/
