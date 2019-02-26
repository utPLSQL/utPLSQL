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

  member function is_null(a_value in anydata) return number is
    l_result integer := 0;
    l_anydata_sql varchar2(4000);
  begin
    if a_value is not null and self.compound_type = 'object' then
     l_anydata_sql := '
        declare
          l_data '||self.data_type||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.get'||self.compound_type||'(l_data);
          :l_data_is_null := case when l_data is null then 1 else 0 end; 
        end;';
        execute immediate l_anydata_sql using in a_value, out l_result;  
    --TODO : Refactor 
    elsif a_value is not null and self.compound_type = 'collection' then
     l_anydata_sql := '
        declare
          l_data '||self.data_type||';
          l_value anydata := :a_value;
          l_status integer;
        begin
          l_status := l_value.get'||self.compound_type||'(l_data);
          :l_data_is_null := case 
            when l_data is null then 1 
            when l_data is empty then 1
            else 0 end; 
        end;';
        execute immediate l_anydata_sql using in a_value, out l_result;  
    else
      l_result := 1;
    end if;
    return l_result;
  end;
  
  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type || case when self.compound_type = 'collection' then ' [ count = '||self.elements_count||' ]' else null end;
  end;
  
  member procedure get_cursor_from_anydata(a_value in anydata, a_refcursor out sys_refcursor) is
    l_anydata_sql varchar2(4000);
    
    function resolve_name(a_object_name in varchar2) return varchar2 is
      l_schema varchar(250);
      l_object varchar(250);
      l_procedure_name varchar(250);
    begin
      ut_metadata.do_resolve(a_object_name,7,l_schema,l_object, l_procedure_name);
      return l_object;
    end;
    
    function get_object_name(a_value anydata) return varchar2 is
    begin
      return resolve_name(ut_metadata.get_collection_element(a_value));
    end;
    
    function get_object_name(a_datatype in varchar2) return varchar2 is
    begin
      return resolve_name(a_datatype);
    end;
    
  begin
     l_anydata_sql := '
        declare
          l_data '||self.data_type||';
          l_value anydata := :a_value;
          l_status integer;
          l_tmp_refcursor sys_refcursor;
          l_refcursor sys_refcursor;
        begin
          l_status := l_value.get'||self.compound_type||'(l_data); '||
          case when self.compound_type = 'collection' then
            ' open l_tmp_refcursor for select value(x) as '||get_object_name(a_value)||' from table(l_data) x;'
          else
            ' open l_tmp_refcursor for select l_data '||get_object_name(self.data_type)||' from dual;'            
          end ||
          ' :l_refcursor := l_tmp_refcursor;
        end;';
        execute immediate l_anydata_sql using in a_value, out a_refcursor;     
  end;
   
  member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata) is
    l_refcursor    sys_refcursor;
    l_ctx      number;
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
    cursor_not_open exception;
    l_cursor_number number;
    
  begin
    self.data_type  := case when a_value is not null then lower(a_value.gettypename()) else 'undefined' end;
    self.compound_type := get_instance(a_value);
    self.extract_path := '/*/*';
    self.data_id    := sys_guid();
    self.self_type := $$plsql_unit;
    self.cursor_details := ut_cursor_details();
    self.is_data_null := is_null(a_value);
    self.elements_count := 0;
    if not self.is_null() then
      get_cursor_from_anydata(a_value,l_refcursor);   
    end if;
    
    ut_compound_data_helper.cleanup_diff;
    if not self.is_null() then
      if l_refcursor%isopen then
        self.elements_count := self.extract_cursor(l_refcursor);
        l_cursor_number  := dbms_sql.to_cursor_number(l_refcursor);
        self.cursor_details  := ut_cursor_details(l_cursor_number);
        dbms_sql.close_cursor(l_cursor_number);         
      elsif not l_refcursor%isopen then
        raise cursor_not_open;
      end if;
    end if;
  end;

  member function get_instance(a_data_value anydata) return varchar2 is
    l_result    varchar2(30);
    l_type      anytype;
    l_type_code integer;
  begin
    if a_data_value is not null then
      l_type_code := a_data_value.gettype(l_type);
      if l_type_code in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection, dbms_types.typecode_object) then
        if l_type_code = dbms_types.typecode_object then
          l_result := 'object';
        else
          l_result := 'collection';
        end if;
      else
        raise_application_error(-20000, 'Data type '||a_data_value.gettypename||' in ANYDATA is not supported by utPLSQL');
      end if;
    end if;
    return l_result;
  end;

  constructor function ut_data_value_anydata(self in out nocopy ut_data_value_anydata, a_value anydata) return self as result
  is
  begin
    init(a_value);
    return;
  end;

  overriding member function compare_implementation(
    a_other             ut_data_value,
    a_match_options     ut_matcher_options,
    a_inclusion_compare boolean := false,
    a_is_negated        boolean := false
  ) return integer is
    l_result            integer := 0;
  begin
    if not a_other is of (ut_data_value_anydata) then
      raise value_error;
    end if;   
    
    l_result := l_result + (self as ut_data_value_refcursor).compare_implementation(a_other,a_match_options,a_inclusion_compare,a_is_negated);
    return l_result;
  end;
  
end;
/
