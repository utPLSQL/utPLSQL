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
  
  overriding member function get_object_info return varchar2 is
  begin
    return self.data_type || case when self.compound_type = 'collection' then ' [ count = '||self.elements_count||' ]' else null end;
  end;
    
  member function get_extract_path(a_data_value anydata) return varchar2 is
    l_path varchar2(10);
  begin
    if self.compound_type = 'object' then 
      l_path := '/*/*';
    else
     case when ut_metadata.has_collection_members(a_data_value) then
       l_path := '/*/*';
       else
        l_path := '/*';
     end case;
    end if; 
    return l_path;
  end;
 
  overriding member procedure extract_cursor(self in out nocopy ut_data_value_anydata, a_value sys_refcursor) 
  is
    c_bulk_rows  constant integer := 10000;
    l_cursor     sys_refcursor := a_value;
    l_ctx        number;
    l_xml        xmltype;
    l_ut_owner   varchar2(250) := ut_utils.ut_owner;
    l_set_id     integer := 0;
    l_elements_count number := 0;
  begin
    -- We use DBMS_XMLGEN in order to:
    -- 1) be able to process data in bulks (set of rows)
    -- 2) be able to influence the ROWSET/ROW tags
    -- 3) be able to influence the way NULL values are handled (empty TAG)
    -- 4) be able to influence the way TIMESTAMP is formatted.
    -- Due to Oracle feature/bug, it is not possible to change the DATE formatting of cursor data
    -- AFTER the cursor was opened.
    -- The only solution for this is to change NLS settings before opening the cursor.
    --
    -- This would work fine if we could use DBMS_XMLGEN.restartQuery.
    --  The restartQuery fails however if PLSQL variables of TIMESTAMP/INTERVAL or CLOB/BLOB are used.
    ut_expectation_processor.set_xml_nls_params();
    l_ctx := dbms_xmlgen.newContext(l_cursor);
    dbms_xmlgen.setNullHandling(l_ctx, dbms_xmlgen.empty_tag);
    dbms_xmlgen.setMaxRows(l_ctx, c_bulk_rows);   
    loop
      l_xml := dbms_xmlgen.getxmltype(l_ctx);
      exit when dbms_xmlgen.getNumRowsProcessed(l_ctx) = 0;
      l_elements_count := l_elements_count + dbms_xmlgen.getNumRowsProcessed(l_ctx);
      execute immediate
      'insert into ' || l_ut_owner || '.ut_compound_data_tmp(data_id, item_no, item_data) ' ||
      'values (:self_guid, :self_row_count, :l_xml)'
      using in self.data_id, l_set_id, l_xml;           
      l_set_id := l_set_id + c_bulk_rows;   
    end loop;
    ut_expectation_processor.reset_nls_params();
    dbms_xmlgen.closeContext(l_ctx);
    self.elements_count := l_elements_count;
  exception
    when others then
      ut_expectation_processor.reset_nls_params();
      dbms_xmlgen.closeContext(l_ctx);
      raise;
  end; 
     
  member procedure init(self in out nocopy ut_data_value_anydata, a_value anydata) is
    l_refcursor    sys_refcursor;
    l_ctx      number;
    l_ut_owner varchar2(250) := ut_utils.ut_owner;
    cursor_not_open exception;
    l_cursor_number number;
    l_anydata_sql varchar2(4000);
    l_cursor_sql  varchar2(2000);

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
    self.data_type  := ut_metadata.get_anydata_typename(a_value);
    self.compound_type := get_instance(a_value);
    self.is_data_null := ut_metadata.is_anytype_null(a_value,self.compound_type);
    self.data_id    := sys_guid();
    self.self_type := $$plsql_unit;
    self.cursor_details := ut_cursor_details();
    
    ut_compound_data_helper.cleanup_diff;
    
    if not self.is_null() then
      self.extract_path := get_extract_path(a_value);
      --get_cursor_from_anydata(a_value,l_refcursor);
    l_anydata_sql := '
        declare
          l_data '||self.data_type||';
          l_value anydata := :a_value;
          l_status integer;
          l_tmp_refcursor sys_refcursor;
        begin
          l_status := l_value.get'||self.compound_type||'(l_data); '||
          case when self.compound_type = 'collection' then
            q'[ open :l_tmp_refcursor for select value(x) as "]'||get_object_name(a_value)||q'[" from table(l_data) x;]'
          else
            q'[ open :l_tmp_refcursor for select l_data as "]'||get_object_name(self.data_type)||q'[" from dual;]'            
          end ||
        'end;';
        execute immediate l_anydata_sql using in a_value, in out l_refcursor; 
        
      if l_refcursor%isopen then
        extract_cursor(l_refcursor);
        l_cursor_number  := dbms_sql.to_cursor_number(l_refcursor);
        self.cursor_details  := ut_cursor_details(l_cursor_number);
        dbms_sql.close_cursor(l_cursor_number);         
      elsif not l_refcursor%isopen then
        raise cursor_not_open;
      end if;
    end if;
    
  exception
    when cursor_not_open then
        raise_application_error(-20155, 'Cursor is not open');
    when others then
      if l_refcursor%isopen then
        close l_refcursor;
      end if;
      raise;  
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
 
  overriding member function is_empty return boolean is
  begin
    if self.compound_type = 'collection' then 
      return self.elements_count = 0;
    else
      raise value_error;
    end if;
  end;  
end;
/
