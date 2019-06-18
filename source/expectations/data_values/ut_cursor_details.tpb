create or replace type body ut_cursor_details as

  member function equals( a_other ut_cursor_details, a_match_options ut_matcher_options ) return boolean is
   l_diffs integer;
  begin   
    select count(1) into l_diffs
      from table(self.cursor_columns_info) a
      full outer join table(a_other.cursor_columns_info) e
        on decode(a.parent_name,e.parent_name,1,0)= 1
       and a.column_name = e.column_name
       and replace(a.column_type,'VARCHAR2','CHAR') =  replace(e.column_type,'VARCHAR2','CHAR')
       and ( a.column_position = e.column_position or a_match_options.columns_are_unordered_flag = 1 )
     where a.column_name is null or e.column_name is null;
    return l_diffs = 0;
  end;

  member procedure desc_compound_data(
    self in out nocopy ut_cursor_details, a_compound_data anytype,
    a_parent_name in varchar2, a_level in integer, a_access_path in varchar2
  ) is
    l_idx                pls_integer := 1;
    l_elements_info      ut_metadata.t_anytype_members_rec;
    l_element_info       ut_metadata.t_anytype_elem_info_rec;
    l_is_collection      boolean;
  begin
    l_elements_info := ut_metadata.get_anytype_members_info( a_compound_data );
    l_is_collection := ut_metadata.is_collection(l_elements_info.type_code);
    if l_elements_info.elements_count is null then
      l_element_info := ut_metadata.get_attr_elem_info( a_compound_data );
      self.cursor_columns_info.extend;
      self.cursor_columns_info(cursor_columns_info.last) :=
        ut_cursor_column(
          l_elements_info.type_name,
          l_elements_info.schema_name,
          null,
          l_elements_info.length,
          a_parent_name,
          a_level,
          l_idx,
          ut_compound_data_helper.get_column_type_desc(l_elements_info.type_code,false),
          ut_utils.boolean_to_int(l_is_collection),
          a_access_path,
          l_elements_info.precision,
          l_elements_info.scale
        );
      if l_element_info.attr_elt_type is not null then
        desc_compound_data(
          l_element_info.attr_elt_type, l_elements_info.type_name,
          a_level + 1, a_access_path || '/' || l_elements_info.type_name
        );
      end if;
    else
      while l_idx <= l_elements_info.elements_count loop
        l_element_info := ut_metadata.get_attr_elem_info( a_compound_data, l_idx );

        self.cursor_columns_info.extend;
        self.cursor_columns_info(cursor_columns_info.last) :=
          ut_cursor_column(
            l_element_info.attribute_name,
            l_elements_info.schema_name,
            null,
            l_element_info.length,
            a_parent_name,
            a_level,
            l_idx,
            ut_compound_data_helper.get_column_type_desc(l_element_info.type_code,false),
            ut_utils.boolean_to_int(l_is_collection),
            a_access_path,
            l_elements_info.precision,
            l_elements_info.scale
          );
        if l_element_info.attr_elt_type is not null then
          desc_compound_data(
            l_element_info.attr_elt_type, l_element_info.attribute_name,
            a_level + 1, a_access_path || '/' || l_element_info.attribute_name
          );
        end if;
        l_idx := l_idx + 1;
      end loop;
    end if;
  end;
    
  constructor function ut_cursor_details(self in out nocopy ut_cursor_details) return self as result is
  begin
    self.cursor_columns_info := ut_cursor_column_tab();
    return;
  end;

  constructor function ut_cursor_details(
    self     in out nocopy ut_cursor_details,
    a_cursor_number in number
  ) return self as result is
    l_columns_count    pls_integer;
    l_columns_desc     dbms_sql.desc_tab3;
    l_is_collection    boolean;
    l_hierarchy_level  integer := 1;
  begin
    self.cursor_columns_info := ut_cursor_column_tab();
    self.is_anydata := 0;
    dbms_sql.describe_columns3(a_cursor_number, l_columns_count, l_columns_desc);

    /**
    * Due to a bug with object being part of cursor in ANYDATA scenario
    * oracle fails to revert number to cursor. We ar using dbms_sql.close cursor to close it
    * to avoid leaving open cursors behind.
    * a_cursor := dbms_sql.to_refcursor(l_cursor_number);
    **/
    for pos in 1 .. l_columns_count loop
      l_is_collection := ut_metadata.is_collection( l_columns_desc(pos).col_schema_name, l_columns_desc(pos).col_type_name );
      self.cursor_columns_info.extend;
      self.cursor_columns_info(self.cursor_columns_info.last) :=
        ut_cursor_column(
          l_columns_desc(pos).col_name,
          l_columns_desc(pos).col_schema_name,
          l_columns_desc(pos).col_type_name,
          l_columns_desc(pos).col_max_len,
          null,
          l_hierarchy_level,
          pos,
          ut_compound_data_helper.get_column_type_desc(l_columns_desc(pos).col_type,true),
          ut_utils.boolean_to_int(l_is_collection),
          null,
          l_columns_desc(pos).col_precision,
          l_columns_desc(pos).col_scale
        );

      if l_columns_desc(pos).col_type = dbms_sql.user_defined_type or l_is_collection then
        desc_compound_data(
          ut_metadata.get_user_defined_type( l_columns_desc(pos).col_schema_name, l_columns_desc(pos).col_type_name ),
          l_columns_desc(pos).col_name,
          l_hierarchy_level + 1,
          l_columns_desc(pos).col_name
        );
      end if;
    end loop;
    return;
  end;

  member function contains_collection return boolean is
    l_collection_elements number;
  begin
    select count(1) into l_collection_elements
      from table(cursor_columns_info) c
     where c.is_collection = 1 and rownum = 1;
    return l_collection_elements > 0;
  end;

  member function get_missing_join_by_columns( a_expected_columns ut_varchar2_list ) return ut_varchar2_list is
    l_result ut_varchar2_list;
  begin
    --regexp_replace(c.access_path,'^\/?([^\/]+\/){1}')
    select fl.column_value
      bulk collect into l_result
      from table(a_expected_columns) fl
     where not exists (
       select 1 from table(self.cursor_columns_info) c
        where regexp_like(c.filter_path,'^/?'||fl.column_value||'($|/.*)' )
       )
     order by fl.column_value;
    return l_result;
  end;

  member procedure filter_columns(self in out nocopy ut_cursor_details, a_match_options ut_matcher_options) is
    l_result            ut_cursor_details := self;
    l_column_tab        ut_cursor_column_tab := ut_cursor_column_tab();
    l_column            ut_cursor_column;
    c_xpath_extract_reg constant varchar2(50) := '^((/ROW/)|^(//)|^(/\*/))?(.*)';
  begin
    if l_result.cursor_columns_info is not null then

      --limit columns to those on the include items minus exclude items
      if a_match_options.include.items.count > 0 then
        -- if include - exclude = 0 then keep all columns
        if a_match_options.include.items != a_match_options.exclude.items then
          with included_columns as (
            select regexp_replace( column_value, c_xpath_extract_reg, '\5' ) col_names
              from table(a_match_options.include.items)
             minus
            select regexp_replace( column_value, c_xpath_extract_reg, '\5' ) col_names
              from table(a_match_options.exclude.items)
          )
          select value(x)
                 bulk collect into l_result.cursor_columns_info
            from table(self.cursor_columns_info) x
           where exists(
                   select 1 from included_columns f where regexp_like(x.filter_path,'^/?'||f.col_names||'($|/.*)' )
                   )
                 or x.hierarchy_level = case when self.is_anydata = 1 then 1 else 0 end ;
        end if;
      elsif a_match_options.exclude.items.count > 0 then
          with excluded_columns as (
            select regexp_replace( column_value, c_xpath_extract_reg, '\5' ) col_names
              from table(a_match_options.exclude.items)
          )
          select value(x)
                 bulk collect into l_result.cursor_columns_info
            from table(self.cursor_columns_info) x
           where not exists(
             select 1 from excluded_columns f where regexp_like(x.filter_path,'^/?'||f.col_names||'($|/.*)' )
           );
      end if;
      
      --Rewrite column order after columns been excluded
      for i in (
      select parent_name, access_path, display_path, has_nested_col,
        transformed_name, hierarchy_level, 
        rownum as new_position, xml_valid_name,
        column_name, column_type, column_type_name, column_schema,
        column_len, column_precision ,column_scale ,is_sql_diffable, is_collection,value(x) col_info
      from table(l_result.cursor_columns_info) x
	  order by x.column_position asc
	  ) loop
        l_column := i.col_info;
        l_column.column_position := i.new_position;
        l_column_tab.extend;
        l_column_tab(l_column_tab.last) := l_column;
      end loop;
      
      l_result.cursor_columns_info := l_column_tab;      
      self := l_result;
    end if;
  end;

  member function get_xml_children(a_parent_name varchar2 := null) return xmltype is
    l_result xmltype;
  begin
    select xmlagg(xmlelement(evalname t.column_name,t.column_type_name))
           into l_result
      from table(self.cursor_columns_info) t
     where (a_parent_name is null and parent_name is null and hierarchy_level = 1 and column_name is not null)
    having count(*) > 0;
    return l_result;
  end;
  
  member function get_root return varchar2 is
    l_root varchar2(250);
  begin
    if self.cursor_columns_info.count > 0 then
      select x.access_path into l_root from table(self.cursor_columns_info) x
      where x.hierarchy_level = 1;
    else
      l_root := null;
    end if;
    return l_root;
  end;  
  
  member procedure strip_root_from_anydata(self in out nocopy ut_cursor_details) is
    l_root varchar2(250) := get_root();
  begin
    self.is_anydata := 1;
    for i in 1..cursor_columns_info.count loop
      self.cursor_columns_info(i).filter_path := '/'||ut_utils.strip_prefix(self.cursor_columns_info(i).access_path,l_root);
    end loop; 
  end;
end;
/
