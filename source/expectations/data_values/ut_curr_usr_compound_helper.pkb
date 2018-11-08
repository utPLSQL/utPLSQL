create or replace package body ut_curr_usr_compound_helper is
    
  type t_type_name_map is table of varchar2(100) index by binary_integer;
  g_type_name_map           t_type_name_map;
  g_anytype_name_map        t_type_name_map;
  g_anytype_collection_name t_type_name_map;
  g_user_defined_type       pls_integer := dbms_sql.user_defined_type;
  g_is_collection           boolean := false;
  g_is_sql_diffable         boolean := true;
 
  procedure set_collection_state(a_is_collection boolean) is
  begin
    --Make sure that we set a g_is_collection only once so we dont reset from true to false.
    if not g_is_collection then
      g_is_collection := a_is_collection;
    end if;
  end;

  procedure set_sql_diff_state(a_is_sql_diff boolean) is
  begin
    --Make sure that we set a g_is_collection only once so we dont reset from false to true.
    if g_is_sql_diffable then
      g_is_sql_diffable := a_is_sql_diff;
    end if;
  end;

  function is_sql_compare_allowed(a_type_name varchar2) return boolean is
  begin
    --clob/blob/xmltype/object/nestedcursor/nestedtable
    
    
    if a_type_name IN (g_type_name_map(dbms_sql.blob_type),
                       g_type_name_map(dbms_sql.clob_type),
                       g_type_name_map(dbms_sql.bfile_type),
                       g_type_name_map(dbms_sql.user_defined_type))
    then    
      return false;
    else
      return true;
    end if;
  end;

  function is_sql_compare_int(a_type_name varchar2) return integer is
  begin  
     --raise_application_error(-20111,'no '||a_type_name||ut_utils.boolean_to_int(is_sql_compare_allowed(a_type_name)));
      return ut_utils.boolean_to_int(is_sql_compare_allowed(a_type_name));
  end;

  function get_column_type(a_desc_rec dbms_sql.desc_rec3, a_desc_user_types boolean := false) return ut_key_anyval_pair is
    l_data ut_data_value;
    l_result ut_key_anyval_pair;
    l_data_type varchar2(500) := 'unknown datatype';  
    
    function is_collection (a_owner varchar2,a_type_name varchar2) return boolean is
      l_type_view varchar2(200) := ut_metadata.get_dba_view('dba_types');
      l_typecode varchar2(100);
    begin
      execute immediate 'select typecode from '||l_type_view ||' 
      where owner = :owner and type_name = :typename'
      into l_typecode using a_owner,a_type_name;   
      
      return l_typecode = 'COLLECTION';
    end;
    
    begin
      if g_type_name_map.exists(a_desc_rec.col_type) then
        l_data := ut_data_value_varchar2(g_type_name_map(a_desc_rec.col_type));
        set_sql_diff_state(is_sql_compare_allowed(g_type_name_map(a_desc_rec.col_type)));
      /*If its a collection regardless is we want to describe user defined types we will return just a name
      and capture that name */
      elsif a_desc_rec.col_type = g_user_defined_type and is_collection(a_desc_rec.col_schema_name,a_desc_rec.col_type_name) then
        l_data := ut_data_value_varchar2(a_desc_rec.col_schema_name||'.'||a_desc_rec.col_type_name);
        set_sql_diff_state(false);
        set_collection_state(true);
      elsif a_desc_rec.col_type = g_user_defined_type and a_desc_user_types then
        if a_desc_rec.col_type_name = 'XMLTYPE'
        then
          l_data := ut_data_value_varchar2(a_desc_rec.col_type_name);
        else
          l_data :=ut_data_value_xmltype(get_user_defined_type(a_desc_rec.col_schema_name,a_desc_rec.col_type_name));
        end if;
        set_sql_diff_state(false);
      elsif a_desc_rec.col_schema_name is not null and a_desc_rec.col_type_name is not null then
        l_data := ut_data_value_varchar2(a_desc_rec.col_schema_name||'.'||a_desc_rec.col_type_name);
        set_sql_diff_state(false);
      end if;
       
      return ut_key_anyval_pair(a_desc_rec.col_name,l_data);
    end;

  function get_columns_info(
    a_columns_tab dbms_sql.desc_tab3, a_columns_count integer, a_desc_user_types boolean := false
  ) return ut_key_anyval_pairs is
    l_result ut_key_anyval_pairs := ut_key_anyval_pairs();
    begin
      for i in 1 .. a_columns_count loop
        l_result.extend;
        l_result(l_result.last) := get_column_type(a_columns_tab(i),a_desc_user_types);
      end loop;
           
      return l_result;
    end;

  procedure get_descr_cursor(
    a_cursor in out nocopy sys_refcursor,
    a_columns_tab in out nocopy ut_key_anyval_pairs,
    a_join_by_tab in out nocopy ut_key_anyval_pairs
  ) is
    l_cursor_number  integer;
    l_columns_count  pls_integer;
    l_columns_desc   dbms_sql.desc_tab3;
  begin
    if a_cursor is null or not a_cursor%isopen then
        a_columns_tab := null;
        a_join_by_tab := null;
    end if;
    l_cursor_number := dbms_sql.to_cursor_number( a_cursor );
    dbms_sql.describe_columns3( l_cursor_number, l_columns_count, l_columns_desc );
    a_cursor := dbms_sql.to_refcursor( l_cursor_number );
    a_columns_tab := get_columns_info( l_columns_desc, l_columns_count, false);
    a_join_by_tab := get_columns_info( l_columns_desc, l_columns_count, true);
  end;
  
  procedure get_columns_info(
    a_cursor in out nocopy sys_refcursor,
    a_columns_info out nocopy xmltype,
    a_join_by_info out nocopy xmltype,
    a_contains_collection out nocopy number,
    a_is_sql_diffable out nocopy number
  ) is
    l_columns_info         xmltype;
    l_join_by_info         xmltype;
    l_result_tmp           xmltype;
    l_columns_tab          ut_key_anyval_pairs;
    l_join_by_tab          ut_key_anyval_pairs;
  begin
    
    get_descr_cursor(a_cursor,l_columns_tab,l_join_by_tab);

    for i in 1..l_columns_tab.COUNT 
    loop
      l_result_tmp := ut_compound_data_helper.get_column_info_xml(l_columns_tab(i));
      select xmlconcat(l_columns_info,l_result_tmp) into l_columns_info from dual; 
    end loop;
    
    for i in 1..l_join_by_tab.COUNT 
    loop
      l_result_tmp := ut_compound_data_helper.get_column_info_xml(l_join_by_tab(i));
      select xmlconcat(l_join_by_info,l_result_tmp) into l_join_by_info from dual; 
    end loop;
    
    select XMLELEMENT("ROW",l_columns_info ),XMLELEMENT("ROW",l_join_by_info )
    into a_columns_info,a_join_by_info from dual;
   
    a_contains_collection := ut_utils.boolean_to_int(g_is_collection);
    a_is_sql_diffable := ut_utils.boolean_to_int(g_is_sql_diffable);
  end;

  function get_anytype_attribute_count (a_anytype anytype) return pls_integer is
            l_attribute_typecode pls_integer;
            l_schema_name              varchar2(32767);
            l_version                  varchar2(32767);
            l_type_name                varchar2(32767);
            l_attributes               pls_integer;
            l_prec                     pls_integer; 
            l_scale                    pls_integer;
            l_len                      pls_integer;
            l_csid                     pls_integer;
            l_csfrm                    pls_integer;
  begin
    l_attribute_typecode := a_anytype.getinfo(
                prec           => l_prec,
                scale          => l_scale,
                len            => l_len,
                csid           => l_csid,
                csfrm          => l_csfrm,
                schema_name    => l_schema_name,
                type_name      => l_type_name,
                version        => l_version,
                numelems       => l_attributes);  
    return l_attributes;
  end;
    
  function get_anytype_attributes_info (a_anytype anytype) return ut_key_value_pairs is
    l_result ut_key_value_pairs := ut_key_value_pairs();
    l_attribute_typecode pls_integer;
    l_aname          varchar2(32767);
    l_prec           pls_integer; 
    l_scale          pls_integer;
    l_len            pls_integer;
    l_csid           pls_integer;
    l_csfrm          pls_integer;
    l_attr_elt_type  anytype;
    l_attributes_cnt pls_integer;
  begin
   l_attributes_cnt := NVL(get_anytype_attribute_count(a_anytype),0);
   
   if l_attributes_cnt > 0 then
   for i in 1..get_anytype_attribute_count(a_anytype) loop
     l_attribute_typecode := a_anytype.getAttrElemInfo(
                pos            => i, --First attribute
                prec           => l_prec,
                scale          => l_scale,
                len            => l_len,
                csid           => l_csid,
                csfrm          => l_csfrm,
                attr_elt_type  => l_attr_elt_type,
                aname          => l_aname);
                
     l_result.extend;
     l_result(l_result.last) := ut_key_value_pair(l_aname, g_anytype_name_map(l_attribute_typecode));
     --check for collection
     if g_anytype_collection_name.exists(l_attribute_typecode) then
       set_collection_state(true);
     end if;
    end loop;
    end if;
    
    
    return l_result;
  end;
  
  function get_user_defined_type(a_owner varchar2,a_type_name varchar2) return xmltype is
    l_anydata anydata;
    l_anytype anytype;
    l_typecode pls_integer;
    l_result xmltype;
    l_columns_tab ut_key_value_pairs := ut_key_value_pairs();      
  begin       
    execute immediate 'declare 
                         l_v '||a_owner||'.'||a_type_name||';
                       begin 
                         :anydata := anydata.convertobject(l_v);
                       end;' USING IN OUT l_anydata;
    
    l_typecode := l_anydata.gettype(l_anytype);
    l_columns_tab := get_anytype_attributes_info(l_anytype);
    
    select xmlagg(xmlelement(evalname key,value))
    into l_result from table(l_columns_tab);
    
    return l_result;
  
  end;
  
  begin
  g_anytype_name_map(dbms_types.typecode_date)             :=' DATE';
  g_anytype_name_map(dbms_types.typecode_number)           := 'NUMBER';
  g_anytype_name_map(dbms_types.typecode_raw)              := 'RAW';
  g_anytype_name_map(dbms_types.typecode_char)             := 'CHAR';
  g_anytype_name_map(dbms_types.typecode_varchar2)         := 'VARCHAR2';
  g_anytype_name_map(dbms_types.typecode_varchar)          := 'VARCHAR';
  g_anytype_name_map(dbms_types.typecode_blob)             := 'BLOB';
  g_anytype_name_map(dbms_types.typecode_bfile)            := 'BFILE';
  g_anytype_name_map(dbms_types.typecode_clob)             := 'CLOB';
  g_anytype_name_map(dbms_types.typecode_timestamp)        := 'TIMESTAMP';
  g_anytype_name_map(dbms_types.typecode_timestamp_tz)     := 'TIMESTAMP WITH TIME ZONE';
  g_anytype_name_map(dbms_types.typecode_timestamp_ltz)    := 'TIMESTAMP WITH LOCAL TIME ZONE';
  g_anytype_name_map(dbms_types.typecode_interval_ym)      := 'INTERVAL YEAR TO MONTH';
  g_anytype_name_map(dbms_types.typecode_interval_ds)      := 'INTERVAL DAY TO SECOND';
  g_anytype_name_map(dbms_types.typecode_bfloat)           := 'BINARY_FLOAT';
  g_anytype_name_map(dbms_types.typecode_bdouble)          := 'BINARY_DOUBLE';
  g_anytype_name_map(dbms_types.typecode_urowid)           := 'UROWID';
  g_anytype_name_map(dbms_types.typecode_varray)           := 'VARRRAY';
  g_anytype_name_map(dbms_types.typecode_table)            := 'TABLE';
  g_anytype_name_map(dbms_types.typecode_namedcollection)  := 'NAMEDCOLLECTION';  
  
  g_anytype_collection_name(dbms_types.typecode_varray)           := 'VARRRAY';
  g_anytype_collection_name(dbms_types.typecode_table)            := 'TABLE';
  g_anytype_collection_name(dbms_types.typecode_namedcollection)  := 'NAMEDCOLLECTION';
  
  
  g_type_name_map( dbms_sql.binary_bouble_type )           := 'BINARY_DOUBLE';
  g_type_name_map( dbms_sql.bfile_type )                   := 'BFILE';
  g_type_name_map( dbms_sql.binary_float_type )            := 'BINARY_FLOAT';
  g_type_name_map( dbms_sql.blob_type )                    := 'BLOB';
  g_type_name_map( dbms_sql.long_raw_type )                := 'LONG RAW';
  g_type_name_map( dbms_sql.char_type )                    := 'CHAR';
  g_type_name_map( dbms_sql.clob_type )                    := 'CLOB';
  g_type_name_map( dbms_sql.long_type )                    := 'LONG';
  g_type_name_map( dbms_sql.date_type )                    := 'DATE';
  g_type_name_map( dbms_sql.interval_day_to_second_type )  := 'INTERVAL DAY TO SECOND';
  g_type_name_map( dbms_sql.interval_year_to_month_type )  := 'INTERVAL YEAR TO MONTH';
  g_type_name_map( dbms_sql.raw_type )                     := 'RAW';
  g_type_name_map( dbms_sql.timestamp_type )               := 'TIMESTAMP';
  g_type_name_map( dbms_sql.timestamp_with_tz_type )       := 'TIMESTAMP WITH TIME ZONE';
  g_type_name_map( dbms_sql.timestamp_with_local_tz_type ) := 'TIMESTAMP WITH LOCAL TIME ZONE';
  g_type_name_map( dbms_sql.varchar2_type )                := 'VARCHAR2';
  g_type_name_map( dbms_sql.number_type )                  := 'NUMBER';
  g_type_name_map( dbms_sql.rowid_type )                   := 'ROWID';
  g_type_name_map( dbms_sql.urowid_type )                  := 'UROWID';  
  g_type_name_map( dbms_sql.user_defined_type )            := 'USER_DEFINED_TYPE'; 
  
end;
/
