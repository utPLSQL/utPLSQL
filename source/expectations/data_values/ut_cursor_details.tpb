create or replace type body ut_cursor_details as

  order member function compare(a_other ut_cursor_details) return integer is
   l_diffs integer;
  begin   
    if self.is_column_order_enforced = 1 then
      select count(1) into l_diffs
      from table(self.cursor_columns_info) a
      full outer join table(a_other.cursor_columns_info) e
      on decode(a.parent_name,e.parent_name,1,0)= 1
      and a.column_name = e.column_name
      and replace(a.column_type,'VARCHAR2','CHAR') =  replace(e.column_type,'VARCHAR2','CHAR')
      and a.column_position = e.column_position
      where a.column_name is null or e.column_name is null;  
    else
      select count(1) into l_diffs
      from table(self.cursor_columns_info) a
      full outer join table(a_other.cursor_columns_info) e
      on decode(a.parent_name,e.parent_name,1,0)= 1
      and a.column_name = e.column_name
      and replace(a.column_type,'VARCHAR2','CHAR') =  replace(e.column_type,'VARCHAR2','CHAR')
      where a.column_name is null or e.column_name is null;   
    end if;
    return l_diffs;
  end;

  member function get_user_defined_type(a_owner varchar2, a_type_name varchar2) return anytype is
    l_anytype anytype;
    not_found exception;
    pragma exception_init(not_found,-22303);
  begin
    if a_type_name is not null then
      begin
        if ut_metadata.IS_OBJECT_VISIBLE('GETANYTYPEFROMPERSISTENT') then
          execute immediate 'begin :l_anytype := getanytypefrompersistent( :a_owner, :a_type_name ); end;'
          using out l_anytype, in nvl(a_owner,sys_context('userenv','current_schema')), in a_type_name;
        else
          execute immediate 'begin :l_anytype := anytype.getpersistent( :a_owner, :a_type_name ); end;'
            using out l_anytype, in nvl(a_owner,sys_context('userenv','current_schema')), in a_type_name;
        end if;
      exception
      when not_found then
        null;
      end;
    end if;
    return l_anytype;
  end;

  member procedure desc_compound_data(
    self in out nocopy ut_cursor_details, a_compound_data anytype,
    a_parent_name in varchar2, a_level in integer, a_access_path in varchar2
  ) is
    l_idx                pls_integer := 1;
    l_elements_info      ut_compound_data_helper.t_anytype_members_rec;
    l_element_info       ut_compound_data_helper.t_anytype_elem_info_rec;
    l_is_collection      boolean;
  begin

    l_elements_info := ut_compound_data_helper.get_anytype_members_info( a_compound_data );

    l_is_collection := is_collection(l_elements_info.type_code);

    if l_elements_info.elements_count is null then

      l_element_info := ut_compound_data_helper.get_attr_elem_info( a_compound_data );

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
          a_access_path
        );
      if l_element_info.attr_elt_type is not null then
        desc_compound_data(
          l_element_info.attr_elt_type, l_elements_info.type_name,
          a_level + 1, a_access_path || '/' || l_elements_info.type_name
        );
      end if;
    else
      while l_idx <= l_elements_info.elements_count loop
        l_element_info := ut_compound_data_helper.get_attr_elem_info( a_compound_data, l_idx );

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
            a_access_path
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
    dbms_sql.describe_columns3(a_cursor_number, l_columns_count, l_columns_desc);
      
    /**
    * Due to a bug with object being part of cursor in ANYDATA scenario
    * oracle fails to revert number to cursor. We ar using dbms_sql.close cursor to close it
    * to avoid leaving open cursors behind.
    * a_cursor := dbms_sql.to_refcursor(l_cursor_number);
    **/
    for pos in 1 .. l_columns_count loop
      l_is_collection := is_collection( l_columns_desc(pos).col_schema_name, l_columns_desc(pos).col_type_name );
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
          null
        );
      if l_columns_desc(pos).col_type = dbms_sql.user_defined_type or l_is_collection then
        desc_compound_data(
          get_user_defined_type( l_columns_desc(pos).col_schema_name, l_columns_desc(pos).col_type_name ),
          l_columns_desc(pos).col_name,
          l_hierarchy_level + 1,
          l_columns_desc(pos).col_name
        );
      end if;
    end loop;
    return;
  end;

  member function is_collection (a_anytype_code in integer) return boolean is
  begin
    return coalesce(a_anytype_code in (dbms_types.typecode_varray,dbms_types.typecode_table,dbms_types.typecode_namedcollection),false);
  end;

  member function is_collection (a_owner varchar2, a_type_name varchar2) return boolean is
  begin
    return is_collection(
      ut_compound_data_helper.get_anytype_members_info(
        get_user_defined_type(a_owner, a_type_name)
      ).type_code
    );
  end;

  member procedure ordered_columns(self in out nocopy ut_cursor_details,a_ordered_columns boolean := false) is
  begin
    self.is_column_order_enforced := ut_utils.boolean_to_int(a_ordered_columns);
  end;

end;
/
