create or replace type body ut_cursor_details as

  order member function compare(a_other ut_cursor_details) return integer is
   l_diffs integer;
  begin   
    if self.is_column_order_enforced = 1 then
      select count(1) into l_diffs
      from table(self.cursor_info) a full outer join table(a_other.cursor_info) e
      on  ( decode(a.parent_name,e.parent_name,1,0)= 1 and a.column_name = e.column_name and 
        REPLACE(a.column_type,'VARCHAR2','CHAR') =  REPLACE(e.column_type,'VARCHAR2','CHAR')
       and  a.column_position = e.column_position )
      where a.column_name is null or e.column_name is null;  
    else
      select count(1) into l_diffs
      from table(self.cursor_info) a full outer join table(a_other.cursor_info) e
      on  ( decode(a.parent_name,e.parent_name,1,0)= 1 and a.column_name = e.column_name and 
        REPLACE(a.column_type,'VARCHAR2','CHAR') =  REPLACE(e.column_type,'VARCHAR2','CHAR'))
      where a.column_name is null or e.column_name is null;   
    end if;
    return l_diffs;
  end;
  
  member procedure get_anytype_members_info(a_anytype anytype, a_attribute_typecode out pls_integer,
    a_schema_name out varchar2, a_type_name out varchar2, a_len out pls_integer,a_elements_count out pls_integer) is
    l_version            varchar2(32767);
    l_prec               pls_integer;
    l_scale              pls_integer;
    l_csid               pls_integer;
    l_csfrm              pls_integer;
  begin
    a_attribute_typecode := a_anytype.getinfo(prec        => l_prec,
                                              scale       => l_scale,
                                              len         => a_len,
                                              csid        => l_csid,
                                              csfrm       => l_csfrm,
                                              schema_name => a_schema_name,
                                              type_name   => a_type_name,
                                              version     => l_version,
                                              numelems    => a_elements_count);
  end;
   
  member procedure getattreleminfo(a_anytype anytype,a_pos pls_integer, a_attribute_typecode out pls_integer,
    a_type_name out varchar2, a_len out pls_integer, a_attr_elt_type out anytype) is
    l_version            varchar2(32767);
    l_prec               pls_integer;
    l_scale              pls_integer;
    l_csid               pls_integer;
    l_csfrm              pls_integer;
    l_attr_elt_type      anytype;
  begin
    a_attribute_typecode := a_anytype.getattreleminfo(pos           => a_pos, --First attribute
                                                      prec          => l_prec,
                                                      scale         => l_scale,
                                                      len           => a_len,
                                                      csid          => l_csid,
                                                      csfrm         => l_csfrm,
                                                      attr_elt_type => l_attr_elt_type,
                                                      aname         => a_type_name);
  end;  
     
  member function get_user_defined_type(a_owner varchar2, a_type_name varchar2)
    return anytype is
    l_anydata  anydata;
    l_anytype  anytype;
    l_typecode pls_integer; 
  begin
    execute immediate 'declare
                       l_v ' || a_owner || '.' ||
                       a_type_name || ';
                       begin
                         :anydata := anydata.convertobject(l_v);
                       end;'
    using in out l_anydata;
   
    l_typecode := l_anydata.gettype(l_anytype);
   
    return l_anytype;
  end;   
  
  member function get_user_defined_type(a_data anydata) return anytype is
    l_anytype  anytype;
    l_typecode pls_integer; 
  begin
    l_typecode:=a_data.gettype(l_anytype);
    return l_anytype;
  end;
   
  member function get_anydata_from_compound_data(a_owner varchar2, a_type_name varchar2,a_type varchar2) return anydata is
    l_anydata anydata;
  begin
    execute immediate '
    declare
      l_obj '||a_owner||'.'||a_type_name||';
    begin
      :anydata := sys.anydata.convert'||a_type||'(l_obj);
    end;'
    using out l_anydata;
    return l_anydata;
  end;
 
  member function get_anytype_of_coll_element(a_collection_owner in varchar2, a_collection_name in varchar2)
     return anytype is
     l_anytype anytype;
     l_anydata anydata;
     l_owner       varchar2(100);
     l_type_name varchar2(100);
   begin
     l_anydata := get_anydata_from_compound_data(a_collection_owner,a_collection_name,'collection'); 
     execute  immediate'
       declare
         l_data '||a_collection_owner||'.'||a_collection_name||';
         l_value anydata := :a_value;
         l_status integer;
         l_loc_query sys_refcursor;
         l_cursor_number number;
         l_columns_count pls_integer;
         l_columns_desc  dbms_sql.desc_tab3;
       begin
         l_status := l_value.getcollection(l_data);
         l_data := '||a_collection_owner||'.'||a_collection_name||q'[();
         l_data.extend;
         open l_loc_query for select l_data(1) from dual;
         l_cursor_number  := dbms_sql.to_cursor_number(l_loc_query);
         dbms_sql.describe_columns3(l_cursor_number,
                                    l_columns_count,
                                    l_columns_desc);
        :owner := l_columns_desc(1).col_schema_name;
        :type_name := l_columns_desc(1).col_type_name;
        dbms_sql.close_cursor(l_cursor_number);
      end;]' using l_anydata, out l_owner,out l_type_name; 
      l_anytype := get_user_defined_type(l_owner, l_type_name); 
      return l_anytype;
   end;
  
  member procedure desc_compound_data(self in out nocopy ut_cursor_details,a_compound_data anytype, 
    a_parent_name in varchar2,a_level in integer, a_access_path in varchar2) is
    l_idx                pls_integer := 1;
    l_elements_count     pls_integer;
    l_attribute_typecode pls_integer;
    l_aname              varchar2(32767);
    l_len                pls_integer;
    l_is_collection      boolean;
    l_schema_name        varchar2(100);
    l_hierarchy_level    integer := a_level; 
    l_object_type        varchar2(10);
    l_anydata            anydata;
    l_attr_elt_type      anytype;
  begin
    get_anytype_members_info(a_compound_data,l_attribute_typecode,l_schema_name,l_aname,l_len,l_elements_count);
    while l_idx <= nvl(l_elements_count,1) loop    
      if l_elements_count is not null then
        getattreleminfo(a_compound_data,l_idx,l_attribute_typecode,l_aname,l_len,l_attr_elt_type);
      elsif l_attribute_typecode in (dbms_types.typecode_table, dbms_types.typecode_varray, dbms_types.typecode_namedcollection) then
        l_attr_elt_type := get_anytype_of_coll_element(l_schema_name, l_aname);
      end if;
      
      l_is_collection := ut_compound_data_helper.is_collection(l_attribute_typecode);
      self.cursor_info.extend;
      self.cursor_info(cursor_info.last) := ut_cursor_column( l_aname,
                                                              l_schema_name,
                                                              null,
                                                              l_len,
                                                              a_parent_name,
                                                              l_hierarchy_level,
                                                              l_idx,
                                                              ut_compound_data_helper.get_column_type_desc(l_attribute_typecode,false),
                                                              ut_utils.boolean_to_int(l_is_collection),
                                                              a_access_path
                                                              );          
      if l_attr_elt_type is not null then
        desc_compound_data(l_attr_elt_type,l_aname,l_hierarchy_level+1,a_access_path||'/'||l_aname);     
      end if;
      l_idx := l_idx + 1;
    end loop;
  end;
    
  constructor function ut_cursor_details(self in out nocopy ut_cursor_details) return self as result is
  begin
    self.cursor_info := ut_cursor_column_tab();
    return;
  end;

  constructor function ut_cursor_details(self     in out nocopy ut_cursor_details
                                      ,a_cursor_number in number)
    return self as result is
    l_cursor_number integer;
    l_columns_count pls_integer;
    l_columns_desc  dbms_sql.desc_tab3;
    l_anydata            anydata;
    l_is_collection      boolean;
    l_object_type        varchar2(10);
    l_hierarchy_level    integer := 1;
    l_anytype            anytype;
   begin
      self.cursor_info := ut_cursor_column_tab();
      dbms_sql.describe_columns3(a_cursor_number,
                                 l_columns_count,
                                 l_columns_desc);
      
      /**
      * Due to a bug with object being part of cursor in anydata scanario
      * oracle fails to revert number to cursor. We ar using dbms_sql.close cursor to close it
      * to avoid leaving open cursors behind.
      * a_cursor := dbms_sql.to_refcursor(l_cursor_number);
      **/   
      for cur in 1 .. l_columns_count loop
         l_is_collection := ut_compound_data_helper.is_collection(l_columns_desc(cur).col_schema_name,l_columns_desc(cur).col_type_name);
         self.cursor_info.extend;
         self.cursor_info(cursor_info.last) := ut_cursor_column(  l_columns_desc(cur).col_name,
                                                                  l_columns_desc(cur).col_schema_name,
                                                                  l_columns_desc(cur).col_type_name,
                                                                  l_columns_desc(cur).col_max_len,
                                                                  null,
                                                                  l_hierarchy_level,
                                                                  cur,
                                                                  ut_compound_data_helper.get_column_type_desc(l_columns_desc(cur).col_type,true),
                                                                  ut_utils.boolean_to_int(l_is_collection),
                                                                  null
                                                                  );                                                                  
        
        if l_columns_desc(cur).col_type = dbms_sql.user_defined_type or  l_is_collection then
          l_object_type := case when l_is_collection then 'collection' else 'object' end;
          l_anydata := get_anydata_from_compound_data(l_columns_desc(cur).col_schema_name, l_columns_desc(cur).col_type_name,
            l_object_type);  
          l_anytype := get_user_defined_type(l_anydata);
          desc_compound_data(l_anytype,l_columns_desc(cur).col_name,l_hierarchy_level+1,l_columns_desc(cur).col_name);
        end if;
      end loop;
      return;
   end;

  member procedure ordered_columns(self in out nocopy ut_cursor_details,a_ordered_columns boolean := false) is
  begin
    self.is_column_order_enforced := ut_utils.boolean_to_int(a_ordered_columns);
  end;

end;
/
